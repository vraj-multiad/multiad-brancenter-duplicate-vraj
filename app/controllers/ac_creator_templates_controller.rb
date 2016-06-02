class AcCreatorTemplatesController < ApplicationController
  before_action :set_ac_creator_template, only: [:show, :edit, :update, :destroy]
  before_action :superuser?, except: [:admin_upload_direct_bundle, :admin_ac_staged]

  # GET /ac_creator_templates
  # GET /ac_creator_templates.json

  def admin_ac
    @keyword = params[:keyword]
    case params['display']
    when 'staged'
      @staged_act = AcCreatorTemplate.where(status: 'staged').order(:id)
    when 'unstaged'
      @unstaged_act = AcCreatorTemplate.where(status: 'unstaged').order(:id)
    when 'processed'
      @processed_act = AcCreatorTemplate.where(status: 'processed').order(:id)
    when 'pre-publish'
      @pre_publish_act = AcCreatorTemplate.where(status: 'pre-publish').order(:id)
    when 'production'
      @production_act = AcCreatorTemplate.where(status: 'production').order(:id)
    when 'unpublished'
      @unpublished_act = AcCreatorTemplate.where(status: 'unpublished').order(:id)
    else
      @staged_act = AcCreatorTemplate.where(status: 'staged').order(:id)
    end

    @keyword_act = []
    if @keyword.present?
      ids = Keyword.where("searchable_type = 'AcCreatorTemplate' and term like '%#{params[:keyword]}%'").pluck(:searchable_id)
      @keyword_act = AcCreatorTemplate.where(expired: false, id: ids).order(:id)
    end

    @uploader = AcCreatorTemplate.new.bundle
    @uploader.use_action_status = false
    @uploader.success_action_redirect = url_for controller: 'ac_creator_templates', action: 'admin_upload_direct_bundle'

    render 'admin_ac'
  end

  # 1) upload form
  def admin_ac_upload
    # refresh form
    @uploader = AcCreatorTemplate.new.bundle
    @uploader.success_action_redirect = url_for controller: 'ac_creator_templates', action: 'admin_upload_direct_bundle'
    render partial: 'admin_ac_upload'
  end

  # 2) carrierwave direct callback
  def admin_upload_direct_bundle
    logger.debug "\n\n admin_upload_direct_bundle started \n\n"

    params
    @ac_creator_template = AcCreatorTemplate.create(upload_params)
    @ac_creator_template.save!
    logger.debug @ac_creator_template.inspect

    filename = @ac_creator_template.bundle.path
    @ac_creator_template.filename = filename.gsub(/.*\//, '')
    @ac_creator_template.status = 'uploaded'
    @ac_creator_template.save
    logger.debug @ac_creator_template.inspect
    # @ac_creator_template

    logger.debug "\n\n admin_upload_direct_bundle finished \n\n"
    redirect_to admin_ac_edit_url + '?token=' + @ac_creator_template.token.to_s
  end

  # 3) name, title form
  def admin_edit_ac
    token = params[:token]
    logger.debug "\n\n admin_edit_ac started \n\n"
    @ac_creator_template = AcCreatorTemplate.find_by(token: token)
    logger.debug "\n\n admin_edit_ac finished \n\n"
    render 'admin_edit_ac'
  end

  # 4) load to server
  def admin_load_ac
    token = params[:token]
    ac_creator_template = AcCreatorTemplate.find_by(token: token)
    logger.debug "\n\n admin_load_ac started \n\n"

    ac_base = AcBase.create(name: params[:name], title: params[:title])
    ac_base.save!

    ac_creator_template.ac_base_id = ac_base.id
    ac_creator_template.name = params[:name]
    ac_creator_template.title = params[:title]
    ac_creator_template.save!

    # send setup xml to MASI
    dispatch_ac_creator_template_request(ac_creator_template)

    logger.debug "\n\n admin_load_ac finished \n\n"
    redirect_to admin_ac_url
  end

  # 5) callback: mark as staged from server
  def admin_ac_staged
    token = params[:token]
    ac_creator_template = AcCreatorTemplate.find_by(token: token)
    ac_creator_template.status = 'staged'
    # ac_creator_template.thumbnail = '/creator_templates/' + ac_creator_template.id.to_s + '/thumbnail_' + ac_creator_template.id.to_s + '.png'
    # ac_creator_template.preview = '/creator_templates/' + ac_creator_template.id.to_s + '/preview_' + ac_creator_template.id.to_s + '.png'
    ac_creator_template.thumbnail = '/creator_templates/' + APP_ID + '/' + ac_creator_template.id.to_s + '/thumbnail_' + ac_creator_template.id.to_s + '.png'
    ac_creator_template.preview = '/creator_templates/' + APP_ID + '/' + ac_creator_template.id.to_s + '/preview_' + ac_creator_template.id.to_s + '_1.png'
    ac_creator_template.save!

    refresh_single_document_xml(ac_creator_template)

    ac_creator_template.ac_base.status = 'staged'
    ac_creator_template.ac_base.save

    render nothing: true
  end

  # 6) ac display
  def admin_ac_display
    @ac_creator_template = AcCreatorTemplate.where(token: params[:token]).first
    init_flag = params[:init]
    @element_coordinates = @ac_creator_template.element_coordinates
    @other_elements = {}
    @steps = {}
    @step_xml = {}
    @text_elements = {}

    @resize_flag = false
    @approval_flag = false
    @bleed_flag = false
    @order_flag = false
    @order_or_download_flag = false
    @email_flag = false
    @inline_email_flag = false
    @marketing_email_flag = false
    @pdf = false
    @jpg = false
    @eps = false
    @access_levels = AccessLevel.all
    @current_access_levels = @ac_creator_template.asset_access_levels.pluck(:access_level_id)

    spec = JSON.parse(@ac_creator_template.document_spec_xml)

    ### Keyword
    @keywords = {}
    @loaded_keywords = {}
    @keyword_types = KeywordType.all.pluck(:name)

    @keyword_types.each do |kt|
      @keywords[kt] = []
      @loaded_keywords[kt] = []
    end

    spec['keywords'].each do |keyword_string|
      keyword = ''
      keyword_type = ''
      if keyword_string.match(/:/)
        keyword_type, keyword = keyword_string.split(':', 2)
        if @keyword_types.include?(keyword_type)
          @keywords[keyword_type].push keyword
        else
          ## assume that the : is part of the keyword like 5:00
          @keywords['search'].push keyword_string
        end
      else
        @keywords['search'] ||= []
        @keywords['search'].push keyword_string
      end
    end

    @ac_creator_template.keywords.each do |k|
      next if k.keyword_type.match(/^(pre-|unpublished-)*system$/)
      next if k.keyword_type.match(/^(pre-|unpublished-)*category$/)
      keyword_type = k.keyword_type.sub(/^pre-|unpublished-/, '')
      @loaded_keywords[keyword_type].push k.term
    end

    spec['elements'].each do |element_name, element|
      @text_elements[element['name']] = element['text'] if element['text'] && element['text'].length > 0
      if element['name'].match(/^\(\d+\).*$/)
        step_number = element_name.sub(/\((\d+)\)(.*)/, '\1').to_i
        element_base_name = element_name.sub(/\((\d+)\)(.*)/, '\2')
        @steps[step_number] = element
        @steps[step_number]['element_name'] = element_name
        @steps[step_number]['element_base_name'] = element_base_name
        @step_xml[step_number] = step_form_xml element_name, element_base_name, element['text'].to_s, element

      else
        @other_elements[element_name] = element
        @other_elements[element_name]['element_base_name'] = element_name
      end
    end

    logger.debug '################3'
    logger.debug @step_xml.inspect

    # MIGRATE
    if @step_xml.length == 0 || !init_flag
      if @ac_creator_template.ac_base.ac_steps
        ### already created steps here you go
        @ac_creator_template.ac_base.ac_steps.each do |ac_step|
          step_data = Hash.from_xml(ac_step.form)['form']
          case step_data['ac_step_type']
          when 'resize'
            @resize_flag = true
          when 'export'
            # export_types lookup?  v2?
            @marketing_email_flag = step_data['marketing_email'] == 'y'
            @email_flag = step_data['email'] == 'y'
            @inline_email_flag = step_data['inline_email'] == 'y'
            @order_flag = step_data['operation'] == 'order'
            @order_or_download_flag = step_data['operation'] == 'order_or_download'
            @bleed_flag = step_data['bleed'] == 'y'
            @approval_flag = step_data['approval'] == 'y'
            @pdf_flag = step_data['pdf'] == 'y'
            @jpg_flag = step_data['jpg'] == 'y'
            @eps_flag = step_data['eps'] == 'y'
            @email_subject = step_data['email_subject']
          end
          next unless ac_step.step_number
          # add title to xml
          step_data['title'] = ac_step.title
          # detect v1 form data
          unless step_data['element_base_name']
            # prepend old naming convention
            case step_data['ac_step_type']
            when 'text'
              step_data['element_name'] = 't_' + step_data['element_name']
            when 'image'
              step_data['element_name'] = 'c_' + step_data['element_name']
            end
            # add new standard element_base_name
            step_data['element_base_name'] = step_data['element_name']
          end
          step_number = ac_step.form_data('step_number').to_i
          @steps[step_number] = step_data.to_xml(root: 'form', dasherize: false)
          @step_xml[step_number] = step_data.to_xml(root: 'form', dasherize: false)
        end
      else
        #### build from scratch
        @steps = { 1 => {}, 2 => {}, 3 => {}, 4 => {}, 5 => {} }
        @step_xml = { 1 => '', 2 => '', 3 => '', 4 => '', 5 => '' }
      end
    end
    @steps.delete(0)
    # allow for new step... we will worry about reordering later
    @steps[9999] = {}
    @step_xml[9999] = ''

    logger.debug "\n\n"
    logger.debug @step_xml.inspect

    render 'admin_ac_display'
  end

  # 7) ac save
  def admin_ac_save
    token = params[:token]
    # keywords = { 'pre-category' => 'adcreator', 'pre-search' => params[:keywords], 'pre-media_type' => params[:media_types], 'pre-topic' => params[:topics] }
    step_xml = params[:step_xml]
    resize_flag = params[:resize_flag]
    approval_flag = params[:approval_flag]
    bleed_flag = params[:bleed_flag]
    order_flag = params[:order_flag]
    order_or_download_flag = params[:order_or_download_flag]
    email_flag = params[:email_flag]
    inline_email_flag = params[:inline_email_flag]
    marketing_email_flag = params[:marketing_email_flag]
    pdf_flag = params[:pdf_flag]
    jpg_flag = params[:jpg_flag]
    eps_flag = params[:eps_flag]
    access_level_ids = params[:access_level_ids]

    act_name = params[:name]
    act_title = params[:title]
    act_publish_at = params[:publish_at]
    act_unpublish_at = params[:unpublish_at]

    email_subject = params[:email_subject] || ''

    ac_creator_template = AcCreatorTemplate.where(token: token).first

    ac_creator_template.asset_access_levels.destroy_all
    if access_level_ids.present?
      access_levels = AccessLevel.where(id: access_level_ids.map(&:to_i))
      if access_levels.count > 0
        access_levels.each do |access_level|
          create_hash = { access_level_id: access_level.id, restrictable_type: 'AcCreatorTemplate', restrictable_id: ac_creator_template.id }
          aal = AssetAccessLevel.new create_hash
          aal.save
        end
      end
    end

    current_ac_steps = AcStep.where(ac_base_id: ac_creator_template.ac_base_id)
    current_ac_steps.destroy_all

    current_keywords = Keyword.where(searchable_type: 'AcCreatorTemplate', searchable_id: ac_creator_template.id)
    current_keywords.destroy_all

    # collect keywords for processing
    keywords = {}
    keyword_types = KeywordType.all.pluck(:name)
    keyword_types.each do |keyword_type|
      keywords['pre-' + keyword_type] = params['pre-' + keyword_type].split(',').uniq - ['', ' ', nil]
    end

    ## add category
    keywords['pre-category'] = ['adcreator']
    # append default keywords
    # keywords['pre-system'].push('all_ac')
    keywords['pre-system'] = [ac_creator_template.name.downcase, ac_creator_template.title.downcase]

    keywords.each do |keyword_type, keywords_array| # keywords.each do |keyword_type, keyword_terms|
      # keywords_array = keyword_terms.split(',') - ['',' ',nil]
      keywords_array.uniq.each do |k|
        k = k.strip
        keyword_hash = { searchable_type: 'AcCreatorTemplate', searchable_id: ac_creator_template.id, keyword_type: keyword_type }
        keyword_hash['term'] = k.downcase
        k = Keyword.new(keyword_hash)
        k.save!
      end
    end

    ### add full_text[]
    if params[:full_text]
      params[:full_text].each do |text|
        k = Keyword.new(searchable_type: 'AcCreatorTemplate', searchable_id: ac_creator_template.id, keyword_type: 'pre-system', term: text.downcase)
        k.save!
      end
    end

    step_number = 1
    step_xml.each do |xml|
      next if xml.strip!.nil?
      logger.debug 'admin_ac_save xml: ' + xml.inspect
      step_form = Hash.from_xml(xml)['form']
      logger.debug 'admin_ac_save step_form: ' + step_form.inspect
      name = ac_creator_template.name + ':' + step_form['element_name']
      title = step_form['title']
      new_step = AcStep.new(ac_base_id: ac_creator_template.ac_base_id, step_number: step_number, name: name, title: title, form: xml)
      new_step.save
      step_number += 1
    end

    ### resize
    logger.debug 'admin_ac_save resize_flag: ' + resize_flag.to_s
    if resize_flag
      name = ac_creator_template.name + ':resize'
      title = 'Resize'
      form = { 'ac_step_type' => 'resize', 'operation' => 'resize' }.to_xml(root: 'form', dasherize: false)
      new_step = AcStep.new(ac_base_id: ac_creator_template.ac_base_id, name:  name, title: title, form: form.to_s)
      new_step.save
    end

    ### export
    logger.debug 'admin_ac_save approval_flag: ' + approval_flag.to_s
    logger.debug 'admin_ac_save bleed_flag: ' + bleed_flag.to_s
    logger.debug 'admin_ac_save order_flag: ' + order_flag.to_s
    logger.debug 'admin_ac_save order_or_download_flag: ' + order_or_download_flag.to_s
    logger.debug 'admin_ac_save email_flag: ' + email_flag.to_s
    logger.debug 'admin_ac_save inline_email_flag: ' + inline_email_flag.to_s
    logger.debug 'admin_ac_save marketing_email_flag: ' + marketing_email_flag.to_s

    name = ac_creator_template.name + ':export'
    title = 'Export'
    export_options = {}
    checkboxes = %w(approval bleed email inline_email marketing_email pdf jpg eps)
    checkboxes.each do |att|
      att_flag = att + '_flag'
      export_options[att] = binding.local_variable_get(att + '_flag').present? ? 'y' : 'n'
    end
    operation = 'export'
    operation = 'order' if order_flag
    operation = 'order_or_download' if order_or_download_flag
    form = export_options.merge('ac_step_type' => 'export', 'operation' => operation, 'email_subject' => email_subject).to_xml(root: 'form', dasherize: false)
    new_step = AcStep.new(ac_base_id: ac_creator_template.ac_base_id, name: name, title: title, form: form.to_s)
    new_step.save

    ac_creator_template.ac_creator_template_type = params[:ac_creator_template_type]
    ac_creator_template.name = act_name if act_name.present?
    ac_creator_template.title = act_title if act_title.present?
    ac_creator_template.publish_at = act_publish_at if act_publish_at.present?
    ac_creator_template.unpublish_at = act_unpublish_at if act_publish_at.present?
    ac_creator_template.publish
    ac_creator_template.save

    redirect_to admin_ac_display_url + '?token=' + token
  end

  def admin_ac_publish
    token = params[:token]
    status = params[:status]
    if token && status
      ac_creator_template = AcCreatorTemplate.find_by(token: token)
      ac_creator_template.status = status
      ac_creator_template.save
      if ac_creator_template.ac_base.present?
        ac_creator_template.ac_base.status = status
        ac_creator_template.ac_base.save
      end
      case status
      when 'unstaged'
        ac_creator_template.keywords.destroy_all
      when 'staged'
        ac_creator_template.publish_now
      when 'production'
        ac_creator_template.publish_now
        ac_creator_template.publish
      when 'unpublished'
        ac_creator_template.unpublish_now
        ac_creator_template.publish
      end
      ac_creator_template.save
    end

    redirect_to admin_ac_url
  end

  def index
    @ac_creator_templates = AcCreatorTemplate.all

    @ac_creator_templates.each do |ac_creator_template|
      next unless /^\//.match(ac_creator_template.document_spec_xml)
      xml_uri = URI(AC_BASE_URL + ac_creator_template.document_spec_xml)
      xml_response = Net::HTTP.get(xml_uri)
      ac_creator_template.document_spec_xml = xml_response
      ac_creator_template.save!
    end
  end

  def refresh_document_xml
    id = params[:id]
    start = params[:start]
    finish = params[:finish]
    if id.to_i > 0
      @ac_creator_templates = AcCreatorTemplate.where(id: id)
    elsif start.to_i > 0 && finish.to_i > start.to_i
      @ac_creator_templates = AcCreatorTemplate.where('id >= ? and id <= ?', start.to_s, finish.to_s)
    elsif start.to_i > 0 && finish.to_i < start.to_i
      finish = start.to_i + 25
      @ac_creator_templates = AcCreatorTemplate.where('id >= ? and id <= ?', start.to_s, finish.to_s)
    else
      @ac_creator_templates = AcCreatorTemplate.all
    end

    @ac_creator_templates.each do |ac_creator_template|
      refresh_single_document_xml(ac_creator_template)
    end
    redirect_to ac_creator_templates_url
  end

  # GET /ac_creator_templates/1
  # GET /ac_creator_templates/1.json
  def show
  end

  # GET /ac_creator_templates/new
  def new
    @ac_creator_template = AcCreatorTemplate.new
  end

  # GET /ac_creator_templates/1/edit
  def edit
  end

  # POST /ac_creator_templates
  # POST /ac_creator_templates.json
  def create
    @ac_creator_template = AcCreatorTemplate.new(ac_creator_template_params)

    respond_to do |format|
      if @ac_creator_template.save
        @ac_creator_template.update_responds_to_attributes params['responds_to_attribute_list'] if params['responds_to_attribute_list'].present?
        @ac_creator_template.update_set_attributes params['set_attribute_list'] if params['set_attribute_list'].present?
        format.html { redirect_to @ac_creator_template, notice: 'Ac creator template was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ac_creator_template }
      else
        format.html { render action: 'new' }
        format.json { render json: @ac_creator_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ac_creator_templates/1
  # PATCH/PUT /ac_creator_templates/1.json
  def update
    respond_to do |format|
      if @ac_creator_template.update(ac_creator_template_params)
        @ac_creator_template.update_responds_to_attributes params['responds_to_attribute_list'] if params['responds_to_attribute_list'].present?
        @ac_creator_template.update_set_attributes params['set_attribute_list'] if params['set_attribute_list'].present?
        format.html { redirect_to @ac_creator_template, notice: 'Ac creator template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ac_creator_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ac_creator_templates/1
  # DELETE /ac_creator_templates/1.json
  def destroy
    @ac_creator_template.destroy
    respond_to do |format|
      format.html { redirect_to ac_creator_templates_url }
      format.json { head :no_content }
    end
  end

  private

  def step_form_xml(element_name, element_base_name, default_copy, element)
    xml_data = { element_name: element_name, element_base_name: element_base_name }
    xml_data['inputs'] = []
    xml_data['upload_inputs'] = []
    xml_data['hooks'] = []
    if element['description'].present?
      element['description'].each_line do |line|
        line = line.chomp
        command, value = line.split('=')
        next unless line.length > 0
        case command
        when 'sub_layer_selection'
          xml_data['ac_step_type'] = 'sub_layer_selection'
          xml_data['sub_layer_selection'] = @ac_creator_template.line_parser_sub_layer_selection_line(value)
          xml_data['operation'] = 'sub_layer_selection'
        when 'sub_layer_text_choice_multiple'
          xml_data['ac_step_type'] = 'sub_layer_text_choice_multiple'
          xml_data['operation'] = 'sub_layer_replace_text_choice_multiple'
          xml_data['search'] = 'Keyword'
          # unlike many other steps, min/max are required
          keyword_name, min_max = value.split(':')
          xml_data['keyword_name'] = keyword_name
          min, max = min_max.split('-')
          xml_data['min_selections'] = min
          xml_data['max_selections'] = max
        when 'layers'
          xml_data['ac_step_type'] = 'layer'
          xml_data['layers'] = @ac_creator_template.line_parser_layers_line(value)
        when 'case_study_drill_down'
          xml_data['ac_step_type'] = 'case_study_drill_down' ### Travelers customization
          xml_data['operation'] = 'replace_text'
        when 'kwikee_product'
          xml_data['ac_step_type'] = 'kwikee_product'
          xml_data['kwikee_product'] = value
          xml_data['operation'] = 'replace_kwikee_product'
          if value.match(/([\d]+)-([\d]+)/)
            min, max = value.split('-')
            xml_data['min_selections'] = min
            xml_data['max_selections'] = max
          else
            xml_data['min_selections'] = value
            xml_data['max_selections'] = value
          end
          # initialize kp_data_array
          xml_data['kp_data'] = []
          xml_data['kp_data_separator'] = '\UE003'
        when 'kp_label'
          xml_data['kp_label'] = value
        when 'kp_data_separator'
          xml_data['kp_data_separator'] = value
        when /^kp_data:/
          kp_data = @ac_creator_template.line_parser_kp_data_line(command, value)
          xml_data['kp_data'] << kp_data
        when 'kp_table_data'
          xml_data['kp_table_data'] = value
        when 'hidden'
          xml_data['hidden'] = true if value.present?
        when 'hook'
          xml_data['hooks'] << @ac_creator_template.line_parser_hook_line(value)
        when 'display'
          xml_data['title'] = value
        when 'editor'
          logger.debug 'test'
          xml_data['inputs'].concat(@ac_creator_template.line_parser_input_line 'editor', value)
          xml_data['default_copy'] = ''
          xml_data['default_copy'] = default_copy if default_copy.to_s != '{}'
        when 'image', 'image(1)'
          image_options = @ac_creator_template.line_parser_image_line value
          xml_data['ac_step_type'] = 'image'
          xml_data['operation'] = 'replace_image'
          if image_options['keyword_name']
            xml_data['search'] = 'Keyword'
            xml_data['keyword_name'] = image_options['keyword_name']
          end
          if image_options['profile_logo']
            xml_data['profile_logo'] = true
            xml_data['ac_step_type'] = 'user_uploaded_image' ### IFB customization
            xml_data['operation'] = 'image_upload' ### IFB customization
          end
          xml_data['upload'] = true if image_options['upload']
          xml_data['auto_submit'] = true if image_options['auto_submit'] || image_options['fill_and_crop'] || image_options['scale_proportional']
          xml_data['fill_and_crop'] = true if image_options['fill_and_crop']
          xml_data['scale_proportional'] = true if image_options['scale_proportional']
          xml_data['align'] = image_options['align'] if image_options['align']
        when /image\(\d+-\d+\)/ # multiple image choice
          ####### Need sample
          _image_options = @ac_creator_template.line_parser_image_line value
          _min, _max = command.sub(/.*\((.*)\)/, '\1').split('-')
          xml_data['ac_step_type'] = 'image'
          xml_data['operation'] = 'replace_multiple_images'
          xml_data['search'] = 'Keyword'
          xml_data['keyword_name'] = value
        when 'clear_steps'
          xml_data['clear_steps'] = @ac_creator_template.line_parser_clear_steps_line value
        when 'require_attributes'
          xml_data['require_attributes'] = true if value.present?
        when 'required'
          xml_data['required'] = true if value.present?
        when 'required_steps'
          xml_data['required_steps'] = @ac_creator_template.line_parser_required_steps_line value
        ##### Text Choice
        when 'text_choice'
          xml_data['ac_step_type'] = 'text_choice'
          xml_data['operation'] = 'replace_text'
          xml_data['search'] = 'Keyword'
          xml_data['keyword_name'] = value
        ##### Text Choice Multiple
        when 'text_choice_multiple'
          xml_data['ac_step_type'] = 'text_choice_multiple'
          xml_data['operation'] = 'replace_text_multiple'
          xml_data['search'] = 'Keyword'
          keyword_name, min_max = value.split(':')
          xml_data['keyword_name'] = keyword_name
          if min_max.match(/([\d]+)-([\d]+)/)
            min, max = min_max.split('-')
            xml_data['min_selections'] = min
            xml_data['max_selections'] = max
          else
            xml_data['min_selections'] = min_max
            xml_data['max_selections'] = min_max
          end
        ##### Text Selection
        when 'text_selection'
          xml_data['ac_step_type'] = 'text_selection'
          xml_data['operation'] = 'replace_text'
          xml_data['search'] = 'Keyword'
          xml_data['keyword_name'] = value
        ##### Text
        when 'text'
          xml_data['ac_step_type'] = 'text'
          xml_data['operation'] = 'replace_text'
          xml_data['search'] = 'AcText.find_by_name'
          xml_data['search_name'] = value
        when 'textarea'
          logger.debug 'test'
          xml_data['inputs'].concat(@ac_creator_template.line_parser_input_line 'textarea', value)
          xml_data['default_copy'] = ''
          xml_data['default_copy'] = default_copy if default_copy.to_s != '{}'
        ######## Text selections
        when /text\(1\)/ # single text choice
          ####### Need sample
          xml_data['ac_step_type'] = 'text'
          xml_data['operation'] = 'replace_text'
          xml_data['search'] = 'Keyword'
          xml_data['keyword_name'] = value
        when /text\(\d+-\d+\)/ # multiple text choice
          ####### Need sample
          _min, _max = command.sub(/.*\((.*)\)/, '\1').split('-')
          xml_data['ac_step_type'] = 'text'
          xml_data['operation'] = 'replace_text'
          xml_data['search'] = 'Keyword'
          xml_data['keyword_name'] = value
        when 'filters'
          xml_data['filters'] = @ac_creator_template.line_parser_filters_line(value)
        when 'input'
          xml_data['inputs'].concat(@ac_creator_template.line_parser_input_line 'input', value)
        when 'upload_input'
          xml_data['upload_inputs'].concat(@ac_creator_template.line_parser_input_line 'input', value)
        when 'targets'
          xml_data['targets'] = value
        when 'triggers'
          xml_data['triggers'] = @ac_creator_template.line_parser_triggers_line(value)
        when 'default_keyword'
          xml_data['default_keyword_name'] = value
        when 'default_sort'
          next unless %w(asc desc).include?(value)
          xml_data['default_sort'] = value
        when 'system_contacts'
          xml_data['system_contacts'] = 1
        when 'user_contacts'
          xml_data['user_contacts'] = 1
        else
          logger.debug 'Unknown parsed sequence for ' + element['element_name'].to_s
          logger.debug line.to_s + "\n"
        end
      end
    end

    xml_data.to_xml(root: 'form', dasherize: false)
  end

  def refresh_single_document_xml(ac_creator_template)
    xml_uri = URI(AC_BASE_URL + '/creator_templates/' + APP_ID + '/' + ac_creator_template.id.to_s + '/p.json')
    preview = '/creator_templates/' + APP_ID + '/' + ac_creator_template.id.to_s + '/preview_' + ac_creator_template.id.to_s + '_'
    xml_response = Net::HTTP.get(xml_uri)
    ac_creator_template.document_spec_xml = xml_response
    ac_creator_template.preview = preview
    ac_creator_template.save!
  end

  def dispatch_ac_creator_template_request(ac_creator_template)
    xml = admin_ac_creator_template_xml(ac_creator_template)
    url = URI.parse("#{ADMIN_URL}/ac_creator_template_#{APP_ID}_#{ac_creator_template.id}.xml")
    request = Net::HTTP::Put.new(url.path)
    # request.content_type = 'text/xml'
    request.body = xml
    response = Net::HTTP.start(url.host, url.port) { |http| http.request(request) }
    logger.debug 'dispatch_ac_creator_template_request'
    logger.debug response.inspect
  end

  def admin_ac_creator_template_xml(ac_creator_template)
    logger.debug 'admin_ac_creator_template_xml id: ' + ac_creator_template.id.to_s
    data = {}
    data[:app_id] = APP_ID
    data[:build_location] = CS_BUILD_LOCATION
    data[:bundle_location] = ac_creator_template.bundle.url
    data[:ac_creator_template_id] = ac_creator_template.id.to_s
    # data[:ac_creator_template_url] = ac_creator_template.bundle.url
    data['ac_creator_template_complete_url'] = admin_ac_staged_url + '?token=' + ac_creator_template.token.to_s

    xml = data.to_xml(root: 'ac_creator_template', dasherize: false)
    logger.debug "\n\n" + xml + "\n\n"
    xml
  end

  def upload_params
    params.permit(:key)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_ac_creator_template
    @ac_creator_template = AcCreatorTemplate.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ac_creator_template_params
    params.require(:ac_creator_template).permit(:name, :title, :bundle, :preview, :thumbnail, :document_spec_xml, :ac_base_id, :folder, :filename, :expired, :status, :publish_at, :unpublish_at)
  end
end
