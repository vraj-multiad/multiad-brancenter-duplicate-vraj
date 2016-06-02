# == Schema Information
#
# Table name: ac_sessions
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  ac_creator_template_id       :integer
#  ac_base_id                   :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  locked                       :boolean          default(TRUE)
#  ac_creator_template_group_id :integer
#

# class AcSession < ActiveRecord::Base
class AcSession < ActiveRecord::Base
  belongs_to :user
  belongs_to :ac_creator_template
  belongs_to :ac_base
  has_many :ac_session_histories

  # validates :ac_creator_template_id, presence: true, numericality: { only_integer: true }
  # validates :ac_base_id, presence: true, numericality: { only_integer: true }

  def lock!
    self.locked = true
    save
  end

  def unlock!
    self.locked = false
    save
  end

  def validate_doc_spec
    return if valid_doc_spec?
    logger.debug '==============ERROR IN SESSION DETECTED================='
    logger.debug '==========ATTEMPTING TO RECOVER VIA REFRESH============='
    logger.debug '==============ERROR IN SESSION DETECTED================='

    @ac_session = update_ac_session(@ac_session.id)
  end

  def valid_doc_spec?
    !document_spec_xml.match(/p\.json$/)
  end

  def step_requirements
    step_requirements = {}
    step_name_requirements = {}
    step_ids = {}
    required_export_steps = []
    step_name_prefix = ac_base.name + ':'

    ac_base.ac_steps.order(id: :asc).each do |ac_step|
      step_name = ac_step.name.gsub(/^#{step_name_prefix}/, '')
      step_ids[step_name] = ac_step.id

      if ac_step.form_data('required_steps').present?
        step_name_requirements[step_name] = ac_step.form_data('required_steps')
      else
        step_name_requirements[step_name] = []
      end

      required_export_steps << ac_step.id if ac_step.form_data('required').present?
      step_requirements['export'] = required_export_steps if step_name == 'export'
    end
    step_name_requirements.each do |step_name, required_steps|
      next if step_name == 'export'
      step_requirements[step_ids[step_name]] = []
      required_steps.each do |required_step|
        step_requirements[step_ids[step_name]] << step_ids[required_step]
      end
    end
    step_requirements
  end

  def finished_steps
    return ac_session_attributes.where(name: 'finished_step').pluck(:value) if ac_session_attributes.present?
    {}
  end

  def cleared_steps
    return ac_session_attributes.where(name: 'cleared_step').pluck(:value) if ac_session_attributes.present?
    {}
  end

  def bleed?
    ac_base.ac_steps.order(step_number: :asc).last.form_data('bleed') == 'y'
  end

  def uuid
    SecureRandom.urlsafe_base64(nil, false)
  end

  def preview(spread_number)
    ac_histories = ac_session_histories
    if ac_histories.count == 0
      # return creator_template.preview
      SECURE_BASE_URL + ac_creator_template.preview + spread_number.to_s + '.png'
    else
      # return document.preview
      SECURE_BASE_URL + '/sessions/' + APP_ID + '/' + id.to_s + '-' + ac_histories.order(id: :asc).last.ac_document.id.to_s + '/preview_' + spread_number.to_s + '.png'
    end
  end

  def layer_previews(spread_number)
    doc_spec = JSON.parse(document_spec_xml)
    previews = []
    current_hidden_layers = hidden_layers
    if doc_spec['elements']['bounding_box_' + spread_number.to_s].present?
      if doc_spec['layers'].present?
        hidden = 'display:block;'
        last_layer_index = doc_spec['layers'].length - 1
        ac_histories = ac_session_histories.order(id: :asc)
        ac_document_id = ''
        ac_document_id = ac_histories.last.ac_document_id if ac_histories.count > 0
        last_layer_index.downto(0).each do |layer_index|
          hidden = 'display:block;'
          hidden = 'display:none;' if current_hidden_layers['names'].include?(doc_spec['layers'][layer_index]['name'])
          if ac_histories.count == 0
            # return creator_template.preview
            previews << { 'url' => SECURE_BASE_URL + ac_creator_template.preview + spread_number.to_s + '_' + layer_index.to_s + '.png', 'hidden' => hidden, 'name' => doc_spec['layers'][layer_index]['name'].gsub(/ /, '_') }
          else
            # return document.preview
            previews << { 'url' => SECURE_BASE_URL + '/sessions/' + APP_ID + '/' + id.to_s + '-' + ac_histories.last.ac_document.id.to_s + '/preview_' + ac_document_id.to_s + '_' + spread_number.to_s + '_' + layer_index.to_s + '.png', 'hidden' => hidden, 'name' => doc_spec['layers'][layer_index]['name'].gsub(/ /, '_') }
          end
        end
      else
        previews << { 'url' => SECURE_BASE_URL + ac_creator_template.preview + spread_number.to_s + '.png', 'hidden' => 'display:block;' }
      end
    else
      previews << { 'url' => preview(spread_number), 'hidden' => 'display:block;' }
    end
    previews
  end

  def pdf
    ac_histories = ac_session_histories
    if ac_histories.count == 0
      # return creator_template.preview
      # SECURE_BASE_URL + ac_creator_template.preview
      nil
    else
      # return document.preview
      SECURE_BASE_URL + '/sessions/' + APP_ID + '/' + id.to_s + '-' + ac_histories.order(id: :asc).last.ac_document.id.to_s + '/export.pdf'
    end
  end

  def document_spec_xml
    if ac_session_histories.present?
      logger.debug 'Using ac_document ' + current_ac_session_history.ac_document.id.to_s + '.json'
      current_ac_session_history.ac_document.document_spec_xml.to_s
    else
      logger.debug 'Using ac_creator_template ' + ac_creator_template.id.to_s + '.json'
      ac_creator_template.document_spec_xml.to_s
    end
  end

  def document_coordinates
    doc_xml = JSON.parse(document_spec_xml)

    coordinates = {}
    coordinates['height'] = doc_xml['size']['height']
    coordinates['width'] = doc_xml['size']['width']
    coordinates
  end

  def spreads
    doc_spec = JSON.parse(document_spec_xml)
    # doc_spec.each do |k, v|
    #   logger.debug k.to_s
    #   # logger.debug doc_spec.inspect
    # end
    doc_spec['spreads'] || { '0' => {} }
  end

  def element_overlay_data(ac_step)
    coordinates = {}
    element_name = ac_step.form_data('element_name')
    ac_step_type = ac_step.form_data('ac_step_type')

    # if element_name.match (/^\(\d+\)/)
    #   ### new standard... old method required strict naming c_ -> g_  or t_
    # else
    #   if ac_step_type == 'text'
    #     element_name = 't_' + element_name
    #   elsif ac_step_type == 'image' || ac_step_type == 'user_uploaded_image' || ac_step_type == 'image_upload'
    #     element_name = 'c_' + element_name
    #   else
    #   end
    # end
    logger.debug ac_step_type
    logger.debug element_name

    doc_xml = JSON.parse(document_spec_xml)
    if doc_xml['elements']
      doc_xml['elements'].each do |_e_name, e|
        # logger.debug 'json: ' + JSON.pretty_generate(e)
        next unless e['name'] == element_name
        coordinates['element_name'] = element_name
        coordinates['spread_number'] = e['spread_number'].to_i
        coordinates['top'] = e['top'].to_f
        coordinates['left'] = e['left'].to_f
        coordinates['bottom'] = e['bottom'].to_f
        coordinates['right'] = e['right'].to_f

        coordinates['height'] = e['bottom'].to_f - e['top'].to_f
        coordinates['width'] = e['right'].to_f - e['left'].to_f

        coordinates['rotation'] = 0
        coordinates['rotation'] = e['rotation'].to_f if e['rotation'].present?

        # coordinates['top_percent'] = (100 * e['top'].to_f / doc_xml['size']['height'].to_f).round(2)
        # coordinates['left_percent'] = (100 * e['left'].to_f / doc_xml['size']['width'].to_f).round(2)

        # coordinates['height_percent'] = (100 * coordinates['height'].to_f / doc_xml['size']['height'].to_f).round(2)
        # coordinates['width_percent'] = (100 * coordinates['width'].to_f / doc_xml['size']['width'].to_f).round(2)
        offset = 0.to_f
        coordinates['top_percent'] = (100 * (e['top'].to_f - offset) / (doc_xml['size']['height'].to_f)).round(2)
        coordinates['left_percent'] = (100 * (e['left'].to_f - offset) / (doc_xml['size']['width'].to_f)).round(2)

        coordinates['height_percent'] = (100 * (coordinates['height'].to_f + (2 * offset)) / (doc_xml['size']['height'].to_f)).round(2)
        coordinates['width_percent'] = (100 * (coordinates['width'].to_f + (2 * offset)) / (doc_xml['size']['width'].to_f)).round(2)

        offset = 0.to_f
        coordinates['resize_mask_top_percent'] = (100 * (e['top'].to_f - offset) / (doc_xml['size']['height'].to_f)).round(2)
        coordinates['resize_mask_left_percent'] = (100 * (e['left'].to_f - offset) / (doc_xml['size']['width'].to_f)).round(2)

        coordinates['resize_mask_height_percent'] = (100 * (coordinates['height'].to_f + (2 * offset)) / (doc_xml['size']['height'].to_f)).round(2)
        coordinates['resize_mask_width_percent'] = (100 * (coordinates['width'].to_f + (2 * offset)) / (doc_xml['size']['width'].to_f)).round(2)

        # offset = 0.to_f
        coordinates['resize_containmentmask_top_percent'] = 0
        coordinates['resize_containmentmask_left_percent'] = 0

        coordinates['resize_containmentmask_height_percent'] = 100
        coordinates['resize_containmentmask_width_percent'] = 100
        # offset = 0.to_f
        # coordinates['resize_containmentmask_top_percent'] = (100 * (e['top'].to_f - offset)/ (doc_xml['size']['height'].to_f ) ).round(2)
        # coordinates['resize_containmentmask_left_percent'] = (100 * (e['left'].to_f - offset)/ (doc_xml['size']['width'].to_f ) ).round(2)

        # coordinates['resize_containmentmask_height_percent'] = (100 * (coordinates['height'].to_f + (2 * offset) )/ (doc_xml['size']['height'].to_f ) ).round(2)
        # coordinates['resize_containmentmask_width_percent'] = (100 * (coordinates['width'].to_f + (2 * offset) )/ (doc_xml['size']['width'].to_f ) ).round(2)

        offset = 0.to_f
        coordinates['resize_containmentbox_top_percent'] = (100 * (e['top'].to_f - offset) / (doc_xml['size']['height'].to_f)).round(2)
        coordinates['resize_containmentbox_left_percent'] = (100 * (e['left'].to_f - offset) / (doc_xml['size']['width'].to_f)).round(2)

        coordinates['resize_containmentbox_height_percent'] = (100 * (coordinates['height'].to_f + (2 * offset)) / (doc_xml['size']['height'].to_f)).round(2)
        coordinates['resize_containmentbox_width_percent'] = (100 * (coordinates['width'].to_f + (2 * offset)) / (doc_xml['size']['width'].to_f)).round(2)

        logger.debug e['name'].to_s
        # logger.debug coordinates.inspect

        label_size = 20
        pos = 5

        coordinates['label_width'] = label_size / coordinates['width'] * 100
        coordinates['label_height'] = label_size / coordinates['height'] * 100

        coordinates['label_top'] =  -pos
        coordinates['label_left'] = -pos

        coordinates['layer_name'] = doc_xml['layer_names'][e['layer']].gsub(/ /, '_')
        # coordinates['label_top'] = (pos / coordinates['top'] * 100) - coordinates['top_percent']
        # coordinates['label_left'] = (pos / coordinates['width'] * 100) - coordinates['left_percent']

        # coordinates['label_top'] = -pos / coordinates['top'] * 100
        # coordinates['label_left'] = -pos / coordinates['width'] * 100
        # coordinates['label_top'] = -pos * coordinates['height_percent'] /100
        # coordinates['label_left'] = -pos *  coordinates['width_percent'] /100

        # .width((labelSize / w)*100 + '%') // set width in %
        # .height((labelSize / h)*100 + '%') // set height in %
        # .css({top: -((pos/h)*100) + '%', left: -((pos/w)*100) + '%'}) // set absolute position in %
        # .find('.label-id').text(index+1);

        # logger.debug e['top'].to_s
        # logger.debug e['bottom'].to_s
        # logger.debug e['left'].to_s
        # logger.debug e['right'].to_s
        # logger.debug (e['right'].to_f - e['left'].to_f).to_s
        # logger.debug (e['bottom'].to_f - e['top'].to_f).to_s
      end

      #### get sub_element
      doc_xml['elements'].each do |_e_name, e|
        match_string = 'element named "' + e['name'] + '" of element named "' + coordinates['element_name'] + '"'
        next unless e['spec'].match(/^#{Regexp.escape(match_string)}/)
        coordinates['resize_top'] = e['top'].to_f
        coordinates['resize_left'] = e['left'].to_f
        coordinates['resize_bottom'] = e['bottom'].to_f
        coordinates['resize_right'] = e['right'].to_f

        coordinates['resize_height'] = e['bottom'].to_f - e['top'].to_f
        coordinates['resize_width'] = e['right'].to_f - e['left'].to_f

        coordinates['resize_rotation'] = 0
        coordinates['resize_rotation'] = e['rotation'].to_f if e['rotation'].present?
        offset = 0.to_f
        coordinates['resize_top_percent'] = (100 * (coordinates['resize_top'].to_f - offset) / (doc_xml['size']['height'].to_f)).round(2)
        coordinates['resize_left_percent'] = (100 * (coordinates['resize_left'].to_f - offset) / (doc_xml['size']['width'].to_f)).round(2)

        coordinates['resize_height_percent'] = (100 * (coordinates['resize_height'].to_f + (2 * offset)) / (doc_xml['size']['height'].to_f)).round(2)
        coordinates['resize_width_percent'] = (100 * (coordinates['resize_width'].to_f + (2 * offset)) / (doc_xml['size']['width'].to_f)).round(2)
      end

    end
    logger.debug 'ccc' + coordinates.inspect
    coordinates
    # crossreference doc xml
    # add to hash
    # return json
  end

  def current_ac_document_id
    current_ac_session_history.ac_document_id if ac_session_histories.count > 0
  end

  def current_ac_session_history_id
    current_ac_session_history.id if ac_session_histories.count > 0
  end

  def current_ac_session_history
    ac_session_histories.order(id: :asc).last if ac_session_histories.count > 0
  end

  def ready?
    logger.debug 'ready?----' + current_ac_session_history_id.to_s
    # true
    if !locked && ac_session_histories.count > 0
      # current_ac_session_history_id = current_ac_session_history.id
      if current_ac_session_history_id > 0
        # false
        logger.debug 'current_ac_session_history_id: ' + current_ac_session_history_id.to_s
        current_ac_session_history = AcSessionHistory.find(current_ac_session_history_id)
        ac_document = current_ac_session_history.ac_document
        if ac_document.status == 'reconciled'
          true
        else
          false
        end
      else
        true  # sanity check
      end
    elsif locked
      false
    else
      # !locked
      true   # new workspace
    end
  end

  def ac_session_attributes
    ac_session_attributes = {}
    ac_session_attributes = current_ac_session_history.ac_session_attributes if ac_session_histories.present? && current_ac_session_history.ac_session_attributes.present?
    ac_session_attributes
  end

  def init_session_history(params_ac_session_id, params_ac_step_id)
    @ac_session = AcSession.find(params_ac_session_id)

    last_ac_session_attributes = []
    last_ac_session_attributes = @ac_session.ac_session_attributes if params_ac_step_id.present?

    last_save_name = ''
    init_default_session_attributes = false
    if @ac_session.ac_session_histories.count > 0
      last_ac_session_history = @ac_session.current_ac_session_history
      # keep only one copy within the session unless already ordered/submitted for approval
      last_save_name = last_ac_session_history.name if last_ac_session_history.saved
      last_ac_session_history.expire!

      last_ac_session_history.save
    end

    init_default_session_attributes = true if params_ac_step_id.present? && @ac_session.ac_session_histories.count == 0
    # create session history with current object.

    @ac_session_history = AcSessionHistory.new
    if last_save_name.present?
      @ac_session_history.name = last_save_name
      @ac_session_history.saved = true
    else
      @ac_session_history.name = 'AUTO ' + @ac_session.ac_creator_template.title + ' | ' + Time.now.strftime('%m/%d/%Y : %l:%M %p')
    end
    @ac_session_history.ac_session_id = params_ac_session_id

    # derive current document_id -> session.current_document_id
    # store in previous_document_id
    @ac_session_history.previous_ac_document_id = @ac_session.current_ac_document_id

    ac_document = AcDocument.new
    ac_document.save
    @ac_session_history.ac_document_id = ac_document.id

    @ac_session_history.save

    # these are the locations of creator output
    session_path = '/sessions/' + APP_ID + '/' + @ac_session.id.to_s + '-' + ac_document.id.to_s + '/'
    ac_document.document_spec_xml = session_path + 'p.json'
    ac_document.preview = session_path + 'preview_1.png'
    ac_document.thumbnail = session_path + 'thumbnail_1.png'

    ac_document.save

    # copy ac_session_attributes from previous
    logger.debug 'init session_attributes: result.ac_step_id.to_s == params[:ac_step_id].to_s' + "\n\n"
    last_ac_session_attributes.each do |result|
      # skip current step
      logger.debug "\n" + '  == session_attributes: ' + result.ac_step_id.to_s + '==' + params_ac_step_id.to_s + "\n"
      next if result.ac_step_id.to_s == params_ac_step_id.to_s
      att = AcSessionAttribute.new(
        ac_session_history_id:  @ac_session_history.id,
        # adcreator_step_id: params[:adcreator_step_id],
        ac_step_id: result.ac_step_id,
        attribute_type: result.attribute_type,
        name: result.name,
        value: result.value
      )
      att.save
    end

    if init_default_session_attributes
      # layers
      hidden_layers = default_hidden_layers
      # steps ->  form_data('layers')?  ->   include?(layer['name']) ? 'hidden' : 'active'
      ac_base.ac_steps.each do |ac_step|
        next if ac_step.id.to_s == params_ac_step_id.to_s
        next unless ac_step.form_data('layers').present?
        ac_step.form_data('layers').each do |layer|
          att = AcSessionAttribute.new(ac_session_history_id: @ac_session_history.id, ac_step_id: ac_step.id, attribute_type: 'system')
          if hidden_layers['names'].include?(layer['name'])
            att.name = 'hidden_layer'
          else
            att.name = 'active_layer'
          end
          att.value = layer['name']
          att.save
        end
      end
    end
    @ac_session_history
  end

  def default_hidden_layers
    layers = { 'ids' => [], 'names' => [] }    # init to defaults
    JSON.parse(document_spec_xml)['layers'].each do |layer|
      next unless layer['name'].match(/^-/)
      layers['names'] << layer['name']
      layers['ids'] << layer['id']
    end
    layers
    # adjust to session
  end

  def hidden_layers
    layers = { 'ids' => [], 'names' => [], 'names_to_ids' => {}, 'ids_to_names' => {} }
    # adjust to session
    if ac_session_histories.present? && ac_session_attributes.present?
      hidden_layer_values = ac_session_attributes.where(name: 'hidden_layer').pluck(:value)
      ac_session_histories.order(id: :desc).each do |ash|
        return layers unless ash.ac_document.present? # ac_creator_template_group processing
        next unless ash.ac_document.status == 'reconciled'
        JSON.parse(ash.ac_document.load_document_spec_xml)['layers'].each do |layer|
          next unless hidden_layer_values.include?(layer['name'])
          layers['names'] << layer['name']
          layers['ids'] << layer['id']
          layers['names_to_ids'][layer['name']] = layer['id']
          layers['ids_to_names'][layer['id']] = layer['name']
        end
        return layers
      end
    end
    # init to defaults
    hidden_layer_values = []
    hidden_layer_values = ac_session_attributes.where(name: 'hidden_layer').pluck(:value) if ac_session_attributes.present?
    JSON.parse(ac_creator_template.document_spec_xml)['layers'].each do |layer|
      if hidden_layer_values.present?
        next unless hidden_layer_values.include?(layer['name'])
      else
        next unless layer['name'].match(/^-/)
      end
      layers['names'] << layer['name']
      layers['ids'] << layer['id']
      layers['names_to_ids'][layer['name']] = layer['id']
      layers['ids_to_names'][layer['id']] = layer['name']
    end
    layers
  end

  def hidden_elements
    elements = []
    # init to defaults
    current_hidden_layers = hidden_layers
    JSON.parse(document_spec_xml)['elements'].each do |element_name, element_data|
      next unless current_hidden_layers['ids'].include?(element_data['layer'].to_s)
      elements << element_name
    end
    elements
    # adjust to session
  end

  def layer_mappings
    mappings = {}
    raw_mappings = {}
    orig_names = {}
    ac_base.ac_steps.each do |ac_step|
      next unless ac_step.layer_mapping.present?
      mapping, raw_mapping, orig_names = ac_step.layer_mapping
      raw_mapping['ac_step_id'] = ac_step.id
      mappings.merge!(mapping)
      raw_mappings.merge!(raw_mapping)
    end
    mappings['raw'] = raw_mappings if raw_mappings.present?
    mappings['orig_names'] = orig_names if raw_mappings.present?
    mappings
  end

  def current_layer
    (layer_mappings['raw'].keys - ['ac_step_id'] - hidden_layers['names'])[0].gsub(/ /, '_')
  end

  def unbork
    return unless locked
    ac_session_histories.last.destroy
    if ac_session_histories.present?
      ash = ac_session_histories.last
      ash.expired = false
      ash.save
    end
    unlock!
  end
end
