# == Schema Information
#
# Table name: ac_steps
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  title       :string(255)
#  actions     :text
#  form        :text
#  ac_base_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#  step_number :integer
#

class AcStep < ActiveRecord::Base
  belongs_to :ac_base
  has_many :ac_session_attributes
  has_many :set_attributes, as: :setable, dependent: :delete_all
  has_many :responds_to_attributes, as: :respondable, dependent: :delete_all
  include Respondable
  include Setable

  def search(current_user, ac_session_history_id, params)
    # logger.debug '   xxx search session_history_id: ' + session_history_id.to_s + ' xxx'
    logger.debug current_user.to_s
    has_admin_rights = current_user.admin? || current_user.superuser?
    search = form_data('search')
    ac_step_type = form_data('ac_step_type')

    keyword_types = ['search']
    keyword_types = ['search', 'pre-search'] if has_admin_rights
    logger.debug '  search|ac_step_type|ac_session_history_id: ' + search.to_s + '|' + ac_step_type.to_s + '|' + ac_session_history_id.to_s

    access_levels = current_user.permissions

    access_enabled = false
    access_ids = nil
    if access_levels.count > 0 && !current_user.superuser?
      access_enabled = true
      access_ids = access_levels.pluck(:access_level_id)
    end

    default_keyword_name = form_data('default_keyword_name')
    default_sort = form_data('default_sort')

    @results = []
    case ac_step_type
    when 'kwikee_product'
      # no base filter setup just yet, it would go here
      if access_enabled
        @results = KwikeeProduct.where(id: AssetAccessLevel.select('restrictable_id').where(restrictable_type: 'KwikeeProduct', asset_access_levels: { access_level_id: access_ids })).order(gtin: :asc)
      else
        @results = KwikeeProduct.all.order(gtin: :asc)
      end
    when 'text_choice', 'text_choice_multiple', 'text_selection', 'sub_layer_text_choice_multiple'
      case search
      when 'keyword', 'Keyword'
        keyword_name = form_data('keyword_name')
        keyword_name = default_keyword_name if params[:default].present? && default_keyword_name.present?
        @results = AcText.joins(:keywords).where(keywords: { term: keyword_name, keyword_type: keyword_types })
        respondable_type = 'AcText'
        if form_data('require_attributes').present? && AcSessionAttribute.where(ac_session_history_id: ac_session_history_id).present?
          @results = respondable_clause(respondable_type, AcSessionAttribute.where(ac_session_history_id: ac_session_history_id))
        elsif form_data('require_attributes').present?
          @results = []
        end
      when 'AcText.where' ### Need to add support for non published text object for admin users
        unless ac_session_history_id.nil?
          unless AcSessionAttribute.where(ac_session_history_id: ac_session_history_id, attribute_type: 'system').nil?
            att = AcSessionAttribute.where(ac_session_history_id: ac_session_history_id, attribute_type: 'system').first
            # p atts
            AcText.joins(:responds_to_attributes).where(responds_to_attributes: { name: att.name, value: att.value })
          end
        end
      end
    when 'text'
      case search
      when 'AcText.all' ### Need to add support for non published text object for admin users
        @results = AcText.all
      when 'keyword', 'Keyword'
        keyword_name = form_data('keyword_name')
        keyword_name = default_keyword_name if params[:default].present? && default_keyword_name.present?
        @results = AcText.joins(:keywords).where(keywords: { term: keyword_name, keyword_type: keyword_types })
        respondable_type = 'AcText'
        if form_data('require_attributes').present? && AcSessionAttribute.where(ac_session_history_id: ac_session_history_id).present?
          @results = respondable_clause(respondable_type, AcSessionAttribute.where(ac_session_history_id: ac_session_history_id))
        elsif form_data('require_attributes').present?
          @results = []
        end
      when 'AcText.find_by_name' ### Need to add support for non published text object for admin users
        search_name = form_data('search_name')
        @results = AcText.where(name: search_name)
      end
      @results &= AcText.joins(:asset_access_levels).where(asset_access_levels: { access_level_id: access_ids }) if access_enabled
    when 'image'
      case search
      when 'AcImage.all' ### Need to add support for non published ac_image object for admin users
        @results = AcImage.all
      when 'keyword', 'Keyword'
        keyword_name = form_data('keyword_name')
        keyword_name = default_keyword_name if params[:default].present? && default_keyword_name.present?
        @results = AcImage.joins(:keywords).where(keywords: { term: keyword_name, keyword_type: keyword_types })
        respondable_type = 'AcImage'
        if form_data('require_attributes').present? && AcSessionAttribute.where(ac_session_history_id: ac_session_history_id).present?
          @results = respondable_clause(respondable_type, AcSessionAttribute.where(ac_session_history_id: ac_session_history_id))
        elsif form_data('require_attributes').present?
          @results = []
        end
      when 'AcImage.find_by_name' ### Need to add support for non published ac_image object for admin users
        search_name = form_data('search_name')
        @results = AcImage.where(name:  search_name)
      end

      # wildcard search system media_type topic ac_image_filter
      if params['keyword'].present?
        keyword_types = Keyword.keyword_types('keyword', has_admin_rights)
        @results &= AcImage.joins(:keywords).where('keywords.term like ?', '%' + params['keyword'].downcase + '%').where(keywords: { keyword_type: keyword_types })
      end
      # exact search system media_type
      if params['media_type'].present?
        keyword_types = Keyword.keyword_types('media_type', has_admin_rights)
        @results &= AcImage.joins(:keywords).where(keywords: { term: params['media_type'], keyword_type: keyword_types })
      end
      # exact search system topic
      if params['topic'].present?
        keyword_types = Keyword.keyword_types('topic', has_admin_rights)
        @results &= AcImage.joins(:keywords).where(keywords: { term: params['topic'], keyword_type: keyword_types })
      end
      # exact search system ac_image_filter
      if params['ac_image_filter'].present?
        keyword_types = Keyword.keyword_types('ac_image_filter', has_admin_rights)
        @results &= AcImage.joins(:keywords).where(keywords: { term: params['ac_image_filter'], keyword_type: keyword_types })
      end

      if access_enabled
        logger.debug 'access_levels enabled'
        @results &= AcImage.joins(:asset_access_levels).where(asset_access_levels: { access_level_id: access_ids })
      end
      @results
    end
    return @results.reverse if params[:default].present? && default_sort.present? && default_sort == 'desc'
    @results
  end

  def options_search(keyword)
    AcText.joins(:keywords).where(keywords: { term: keyword, keyword_type: 'search' }).pluck(:title, :creator)
  end

  def parse_inputs(key)
    inputs = form_data(key)
    if inputs
      logger.debug inputs.inspect
      i = inputs
      i = [i] if i.is_a?(Hash)
      i
      # Array(inputs['input'])
    else
      []
    end
    inputs || []
  end

  def inputs
    parse_inputs('inputs')
  end

  def upload_inputs
    parse_inputs('upload_inputs')
  end

  def layer_mapping
    layer_data = form_data('layers')
    return {} if layer_data.nil?
    layers = []
    raw_layers = []
    orig_names = {}
    layer_data.each do |layer|
      raw_layers << layer['name']
      layers << layer['name'].tr(' ', '_')
      orig_names[layer['name'].tr(' ', '_')] = layer['name']
    end
    mapped = {}
    layers.each do |layer|
      mapped[layer] = layers - [layer]
    end
    raw_mapped = {}
    raw_layers.each do |raw_layer|
      raw_mapped[raw_layer] = raw_layers - [raw_layer]
    end
    [mapped, raw_mapped, orig_names]
  end

  def form_data(key)
    return unless form.present?
    form_hash = Hash.from_xml(form.to_s)
    form_hash['form'][key]
  end

  def form_hash
    Hash.from_xml(form).merge('name' => name, 'title' => title, 'id' => id, 'ac_base_id' => ac_base_id)
  end

  def step_type
    form_data('step_type')
  end

  def params(ac_session_attributes)
    params = { ac_step_id: id }
    # get operation
    operation = form_data('operation')
    case operation
    when 'layer'
      # do nothing
    when 'sub_layer_selection'
      # sub_layer_selection
      params[:sub_layer_selection] = session_data(ac_session_attributes, 'sub_layer_selection')
    when 'sub_layer_replace_text_choice_multiple'
      # sub_layer_selection
      params[:sub_layer_selection] = session_data(ac_session_attributes, 'sub_layer_selection')
      # text_choice_ids
      params[:text_choice_ids] = session_data(ac_session_attributes, 'text_choice_ids').split(',')
    when 'order_vista'
      # export_formats
      params[:export_formats] = session_data(ac_session_attributes, 'export_formats').split(',')
      # bleed
      params[:bleed] = session_data(ac_session_attributes, 'bleed')
    when 'order', 'order_or_download', 'export'
      # export_formats
      params[:export_formats] = session_data(ac_session_attributes, 'export_formats').split(',')
      # bleed
      params[:bleed] = session_data(ac_session_attributes, 'bleed')
    when 'resize'
      # resize_height
      params[:resize_height] = session_data(ac_session_attributes, 'resize_height')
      # resize_width
      params[:resize_width] = session_data(ac_session_attributes, 'resize_width')
    when 'replace_image'
      # option_type
      params[:option_type] = session_data(ac_session_attributes, 'option_type')
      # option_id
      params[:option_id] = session_data(ac_session_attributes, 'option_id')
      # cs_bounds
      params[:resize_top] = session_data(ac_session_attributes, 'resize_top')
      params[:resize_bottom] = session_data(ac_session_attributes, 'resize_bottom')
      params[:resize_left] = session_data(ac_session_attributes, 'resize_left')
      params[:resize_right] = session_data(ac_session_attributes, 'resize_right')
    when 'replace_kwikee_product'
      # kwikee_product_ids
      params[:kwikee_product_ids] = session_data(ac_session_attributes, 'kwikee_product_ids').split(',')
    when 'replace_text'
      # option_id
      params[:option_id] = session_data(ac_session_attributes, 'option_id')
    when 'replace_text_multiple'
      # text_choice_ids
      params[:text_choice_ids] = session_data(ac_session_attributes, 'text_choice_ids').split(',')
    when 'image_upload'
      if params[:expire]
        # option_id
        params[:option_id] = session_data(ac_session_attributes, 'option_id')
      else
        # option_type
        params[:option_type] = session_data(ac_session_attributes, 'option_type')
        # option_id
        params[:option_id] = session_data(ac_session_attributes, 'option_id')
        # cs_bounds
        params[:resize_top] = session_data(ac_session_attributes, 'resize_top')
        params[:resize_bottom] = session_data(ac_session_attributes, 'resize_bottom')
        params[:resize_left] = session_data(ac_session_attributes, 'resize_left')
        params[:resize_right] = session_data(ac_session_attributes, 'resize_right')
      end
    end
    params
  end

  def session_data(ac_session_attributes, attribute_name)
    ac_session_attributes.each do |attr|
      return attr.value if attr.ac_step_id == id && attr.name == attribute_name
    end
    ''
  end

  private
  def respondable_clause(respondable_type, atts)
    clauses = []
    clause_variables = []
    atts.each do |att|
      clauses << '(responds_to_attributes.name = ? and (responds_to_attributes.value = ? or responds_to_attributes.value = \'*\') and responds_to_attributes.respondable_type = ?)'
      clause_variables += [att.name, att.value, respondable_type]
    end
    @results.joins(:responds_to_attributes).where(clauses.join(' OR '), *clause_variables)
  end
end
