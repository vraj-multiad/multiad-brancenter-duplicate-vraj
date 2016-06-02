# class AcSessionsController < ApplicationController
class AcSessionsController < ApplicationController
  include CustomAcSessionsControllerMethods
  include CreatorServerCommands
  include ApplicationHelper
  skip_before_filter :verify_authenticity_token
  before_action :set_ac_session, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?, except: [:export_finished, :reconcile_document]

  def export_panel
    ac_step = AcStep.find(params[:ac_step_id])
    @ac_session = AcSession.find(params[:ac_session_id])
    fail unless ac_step.form_data('operation').present?
    render partial: 'export_panel', locals: { ac_step: ac_step }
  end

  def user_email_lists_select
    email_subject = ''
    email_subject = AcStep.find(params[:ac_step_id]).form_data('email_subject') if params[:ac_step_id].present?
    ac_session_history = current_user.ac_sessions.find_by(id: params[:ac_session_id]).current_ac_session_history
    email_subject = ac_session_history.first_ac_session_attribute('@email_subject') if ac_session_history.present? && ac_session_history.first_ac_session_attribute('@email_subject').present?

    render partial: 'user_email_lists_select', locals: { email_subject: email_subject, email_lists: current_user.email_lists }
  end

  def load_step_kwikee_products
    ac_step_id = params[:ac_step_id]
    _ac_session_history_id = params[:ac_session_history_id]
    _keyword = params[:keyword]
    _media_type = params[:media_type]
    _topic = params[:topic]
    has_admin_rights = current_user.admin? || current_user.superuser?

    access_ids = current_user.permissions.pluck(:id)

    results = KwikeeProduct.includes(:asset_access_levels).where(asset_access_levels: { access_level_id: access_ids })

    if params['keyword'].present?
      keyword_types = %w(search system media_type topic)
      keyword_types = %w(search pre-search system pre-system media_type pre-media_type topic pre-topic) if has_admin_rights
      keyword_results = KwikeeProduct.joins(:keywords).where(keywords: { keyword_type: keyword_types }).where('keywords.term like ?', '%' + params['keyword'].downcase + '%') + KwikeeProduct.joins(:user_keywords).where(user_keywords: { user_keyword_type: 'keyword' }).where('user_keywords.term like ?', '%' + params['keyword'].downcase + '%')
      if [5, 6, 10, 12, 13, 14].include?(params['keyword'].strip.length)
        keyword_param = '%' + params['keyword'].strip + '%'
        keyword_results += KwikeeProduct.where('gtin like ?', keyword_param)
      end
      results &= keyword_results
    end
    if params['media_type'].present?
      keyword_types = %w(media_type)
      keyword_types << 'pre-media_type' if has_admin_rights
      results &= KwikeeProduct.joins(:keywords).where(keywords: { term: params['media_type'], keyword_type: keyword_types })
    end
    if params['topic'].present?
      keyword_types = %w(topic)
      keyword_types << 'pre-topic' if has_admin_rights
      results &= KwikeeProduct.joins(:keywords).where(keywords: { term: params['topic'], keyword_type: keyword_types })
    end
    if params['search_access_levels'].present?
      # already pre-filtered restrictable
      results &= KwikeeProduct.joins(:asset_access_levels).where(asset_access_levels: { access_level_id: params['search_access_levels'] })
    end

    ac_step = AcStep.find(ac_step_id)
    render partial: 'load_step_kwikee_products', locals: { ac_step: ac_step, results: results }
  end

  def load_step_logos
    _ac_step_id = params[:ac_step_id]
    _ac_session_history_id = params[:ac_session_history_id]
    _keyword = params[:keyword]
    _media_type = params[:media_type]
    _topic = params[:topic]
    permissions = current_user.permissions.pluck(:id)

    results = DlImage.joins(:keywords).where(keywords: { term: 'logos', keyword_type: 'media_type' }).joins(:asset_access_levels).where(asset_access_levels: { access_level_id: permissions })

    if params['keyword'].present?
      keyword_types = %w(search system media_type topic)
      keyword_types = %w(search pre-search system pre-system media_type pre-media_type topic pre-topic) if if_admin
      keyword_results = DlImage.joins(:keywords).where(keywords: { keyword_type: keyword_types }).where('keywords.term like ?', '%' + params['keyword'].downcase + '%') + DlImage.joins(:user_keywords).where(user_keywords: { user_keyword_type: 'keyword' }).where('user_keywords.term like ?', '%' + params['keyword'].downcase + '%')
      results &= keyword_results
    end

    %w(media_type topic ac_image_filter).each do |filter_type|
      results &= dl_image_filter(filter_type, params) if params[filter_type].present?
    end

    render partial: 'load_step_logos', locals: { results: results }
  end

  def dl_image_filter(filter_type, params)
    has_admin_rights = current_user.admin? || current_user.superuser?
    keyword_types = [filter_type]
    keyword_types << 'pre-' + filter_type.to_s if has_admin_rights
    DlImage.joins(:keywords).where(keywords: { term: params[filter_type], keyword_type: keyword_types })
  end

  def load_step_images
    ac_step_id = params[:ac_step_id]
    ac_session_id = params[:ac_session_id]
    _keyword = params[:keyword]
    _media_type = params[:media_type]
    _topic = params[:topic]

    ac_step = AcStep.find(ac_step_id)
    ac_session_history_id = AcSession.find(ac_session_id).current_ac_session_history_id
    results = ac_step.search(current_user, ac_session_history_id, params)

    render partial: 'load_step_images', locals: { results: results, ac_step: ac_step }
  end

  def undo
    @ac_session = AcSession.find(params[:id])
    logger.debug 'count histories: ' + @ac_session.ac_session_histories.length.to_s
    if @ac_session.ac_session_histories.present?
      undo_session = @ac_session.current_ac_session_history
      undo_session.expired = true
      undo_session.ac_session = nil
      undo_session.save
      logger.debug @ac_session.current_ac_session_history.inspect
      # @ac_session.ac_session_histories.last.destroy
      # @ac_session.ac_session_histories.reset_column_information
      logger.debug 'count histories (after destroy): ' + @ac_session.ac_session_histories.length.to_s
      if @ac_session.ac_session_histories.present?
        logger.debug @ac_session.current_ac_session_history.inspect
        current_session_history = @ac_session.current_ac_session_history
        current_session_history.expired = false
        current_session_history.save
      end
    end

    workspace
  end

  def reconcile_document
    ac_document_id = params[:id]
    _ac_document = _reconcile_document(ac_document_id)

    render nothing: true
  end

  def export_finished
    ac_document_id = params[:id]
    @ac_document = _reconcile_document(ac_document_id)

    # update downloads
    @ac_export = @ac_document.ac_session_histories.first.ac_exports.first

    send_marketing_email

    if @ac_export.email_address.nil? || @ac_export.email_address.empty?
      logger.debug 'no email sent for: ' + @ac_export.to_yaml
    elsif @ac_export.email_address.present? && @ac_export.inline_email?
      send_inline_email
    else
      send_export_email
    end

    send_order_emails

    render nothing: true
  end

  def send_marketing_email
    # submission validation is in the model for this call
    MarketingEmailWorker.perform_in(1.seconds, 'sendgrid_submit_email', @ac_export.marketing_emails.first.id) if @ac_export.marketing_emails.present?
  end

  def send_inline_email
    logger.debug @ac_export.to_yaml
    uri = URI(AC_BASE_URL + @ac_export.location)
    email_body = Net::HTTP.get(uri)
    recipient = @ac_export.email_address
    UserMailer.inline_email(@ac_export.email_subject, email_body, recipient, @ac_export.ac_session_history.ac_session.user.email_address).deliver
  end

  def send_export_email
    UserMailer.ac_export_email(@ac_export, current_language).deliver unless @ac_export.approval_required?
  end

  def send_order_emails
    @ac_document.ac_session_histories.first.ac_session.ac_base.ac_steps.each do |ac_step|
      next unless ac_step.form_data('ac_step_type') == 'export' && ac_step.form_data('operation') == 'order'
      UserMailer.ac_export_order_confirmation_email(@ac_export, current_language).deliver
      UserMailer.ac_export_order_fulfillment_email(@ac_export, current_language).deliver
    end
  end

  # GET /ac_sessions
  # GET /ac_sessions.json
  def index
    @ac_sessions = AcSession.all
  end

  # GET /ac_sessions/1
  # GET /ac_sessions/1.json
  def show
  end

  # GET /ac_sessions/new
  def new
    @ac_session = AcSession.new
  end

  # GET /ac_sessions/1/edit
  def edit
  end

  # POST /ac_sessions
  # POST /ac_sessions.json
  def create
    @ac_session = AcSession.new(ac_session_params)

    respond_to do |format|
      if @ac_session.save
        format.html { redirect_to @ac_session, notice: 'Ac session was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ac_session }
      else
        format.html { render action: 'new' }
        format.json { render json: @ac_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ac_sessions/1
  # PATCH/PUT /ac_sessions/1.json
  def update
    respond_to do |format|
      if @ac_session.update(ac_session_params)
        format.html { redirect_to @ac_session, notice: 'Ac session was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ac_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ac_sessions/1
  # DELETE /ac_sessions/1.json
  def destroy
    @ac_session.destroy
    respond_to do |format|
      format.html { redirect_to ac_sessions_url }
      format.json { head :no_content }
    end
  end

  def start
    # create session
    @ac_session = AcSession.new
    @ac_session.ac_creator_template_id = params[:ac_creator_template_id]
    @ac_session.ac_base_id = params[:ac_base_id]
    @ac_session.user_id = current_user.id
    @ac_session.save

    set_current_ac_session(@ac_session.id)
    # verify document_xml_spec
    ac_creator_template = AcCreatorTemplate.find(params[:ac_creator_template_id])
    ## logger.debug 'ac_creator_template: ' + ac_creator_template.inspect

    # logger.debug ac_creator_template.document_spec_xml.inspect
    if /^\//.match(ac_creator_template.document_spec_xml)
      xml_uri = URI(AC_BASE_URL + ac_creator_template.document_spec_xml)
      xml_response = Net::HTTP.get(xml_uri)
      ac_creator_template.document_spec_xml = xml_response
      ac_creator_template.save!
    end
    @ac_session.locked = false
    @ac_session.save

    respond_to do |format|
      format.html { redirect_to action: 'workspace', id: @ac_session.id, uuid: @ac_session.uuid }
      format.json { render json: @ac_session, status: :created, location: @ac_session }
    end
  end

  def save
    @ac_session = AcSession.find(params[:ac_session_id])
    save_name = params[:save_name].strip
    current_ac_session_history = @ac_session.current_ac_session_history
    add_user_keyword = true
    if save_name.nil? || save_name == ''
      save_name = @ac_session.ac_creator_template.title + ' | ' + current_ac_session_history.updated_at.localtime.strftime('%m/%d/%Y : %l:%M %p')
      add_user_keyword = false
    end
    current_ac_session_history.name = save_name
    current_ac_session_history.saved = true
    current_ac_session_history.save

    ### essentially a save as for loaded sessions... this will re-enable the initial session history for a given loaded document.
    load_attribute = current_ac_session_history.ac_session_attributes.where(name: 'load_ac_session_history_id').first
    logger.debug load_attribute
    if load_attribute
      load_ac_session_history = AcSessionHistory.find(load_attribute.value.to_i)
      load_ac_session_history.expired = false
      load_ac_session_history.save
    end

    # add keyword for save name
    if add_user_keyword
      create_hash = { user_id: @ac_session.user_id, term: save_name.downcase, categorizable_type: 'UserSavedAds', categorizable_id: current_ac_session_history.id, user_keyword_type: 'keyword' }
      # logger.debug 'create_hash: ' + create_hash.inspect
      uk = UserKeyword.new create_hash
      uk.save
    end

    respond_to do |format|
      format.html { redirect_to action: 'workspace', id: @ac_session.id, uuid: @ac_session.uuid }
      format.json { render json: @ac_session, status: :created, location: @ac_session }
    end
  end

  def load
    ac_session_id = params[:ac_session_id]
    load_ac_session_history_id = params[:ac_session_history_id]

    load_ac_session_history = AcSessionHistory.find(load_ac_session_history_id)

    if load_ac_session_history.ac_session.user_id.to_s == current_user.id.to_s && load_ac_session_history.ac_session_id.to_s == ac_session_id.to_s

      # create session
      @ac_session = AcSession.create(ac_creator_template_id: load_ac_session_history.ac_session.ac_creator_template_id, ac_base_id: load_ac_session_history.ac_session.ac_base_id, user_id: current_user.id)

      set_current_ac_session(@ac_session.id)

      # session_history
      @ac_session_history = @ac_session.init_session_history(@ac_session.id, nil)
      logger.debug load_ac_session_history.name
      @ac_session_history.name = load_ac_session_history.name
      @ac_session_history.saved = true
      @ac_session_history.save

      # load session_history_attributes
      init_load_session_attributes(load_ac_session_history)

      cs = nil
      aws = nil

      completion_url = ''
      completion_url = APP_DOMAIN + '/adcreator/reconcile_document?id=' + @ac_session_history.ac_document_id.to_s if APP_DOMAIN !~ /localhost/

      xml = load_ac_xml(@ac_session_history, load_ac_session_history.ac_session_id, load_ac_session_history.ac_document_id, cs, aws, completion_url)
      load_ac_session_history.expire!

      #### ISSUE may want to have an unexpire routine if dispatch_request fails... they will not be able to open their ad.

      direct_request(@ac_session, xml, '')

    else
      redirect_to action: my_documents_url
    end
  end

  def init_load_session_attributes(load_ac_session_history)
    load_ac_session_history.ac_session_attributes.each do |result|
      next if result.name == 'load_ac_session_history_id'

      @ac_session_history.ac_session_attributes.create(ac_step_id: result.ac_step_id, attribute_type: result.attribute_type, name: result.name, value: result.value)
    end
    @ac_session_history.ac_session_attributes.create(ac_step_id: nil, attribute_type: 'system', name: 'load_ac_session_history_id', value: load_ac_session_history.id)
  end

  def load_ac_xml(ac_session_history, load_ac_session_id, load_ac_document_id, cs, aws, completion_url)
    # cs commands cannot be null for dispatch
    cs = 'version\n' if cs.nil?
    xml = {}
    xml['session_id'] = ac_session_history.ac_session_id.to_s
    xml['app_id'] = APP_ID
    xml['build_name'] = CS_BUILD_NAME
    xml['build_location'] = CS_BUILD_LOCATION
    xml['completion_url'] = completion_url
    xml['secure_base_url'] = SECURE_BASE_URL
    xml['session_history_id'] = ac_session_history.id.to_s
    xml['document_id'] = ac_session_history.ac_document_id.to_s
    xml['current_document_id'] = ''
    xml['creator_template_id'] = ac_session_history.ac_session.ac_creator_template_id.to_s
    xml['load_session_id'] = load_ac_session_id.to_s
    xml['load_document_id'] = load_ac_document_id.to_s
    xml['export_files'] = nil
    xml['export_location'] = nil
    xml['aws'] = ''
    xml['footnotes'] = nil
    xml['delete_on_export'] = nil

    xml['layers'] = ''

    xml['spreads'] = ''
    xml['active_layer'] = ''
    xml['active_layers'] = {}
    xml['hidden_layers'] = {}

    xml['aws'] = aws || ''
    xml['commands'] = cs
    xml_string = xml.to_xml(root: 'xml', dasherize: false)
    # logger.debug "\n\n" + xml_string + "\n\n"

    xml_string
  end

  # GET /workspace/1
  # GET /workspace/1.json
  def workspace
    @template_canvas_only = params[:template_canvas_only]
    logger.debug 'template_canvas_only ' + @template_canvas_only.to_s
    @set_spread = params[:set_spread] || 1
    @ac_session = update_ac_session(params[:id])
    @current_user = current_user

    return render partial: 'template_canvas', content_type: 'text/html' if @template_canvas_only == '1'
    ac_session_history = @ac_session.current_ac_session_history
    @save_name = ''
    @save_name = ac_session_history.saved ? ac_session_history.name : '' if ac_session_history.present?

    @email_list = EmailList.new.sheet
    @email_list.use_action_status = false
    @email_list.success_action_redirect = url_for controller: 'email_lists', action: 'create_list'

    @uploader = UserUploadedImage.new.image_upload
    @uploader.success_action_redirect = url_for controller: 'user_uploaded_images', action: 'upload_direct_ac_image'
    @wysiwyg_data = {}
    @element_scales = {}

    text_areas = {}
    @ac_session.ac_base.ac_steps.each do |ac_step|
      operation = ac_step.form_data('operation')
      next unless operation.present? && operation == 'replace_text'
      element_name = ac_step.form_data('element_name')
      ac_step.form_data('inputs').each do |input|
        logger.debug 'input: ' + input.inspect
        if input['type'] == 'textarea'
          text_areas[element_name] = 'textarea'
        elsif input['type'] == 'editor'
          text_areas[element_name] = 'editor'
        end
      end
    end

    parse_wysiwyg_data = true
    if @ac_session.ac_session_histories.present? && @ac_session.current_ac_session_history.ac_exports.present?
      # logger.debug 'export detected'
      export_type_collection = @ac_session.current_ac_session_history.ac_session_attributes.where(name: 'export_type')
      return render_export(export_type_collection.first.value) if export_type_collection.present?
    end

    @attributes = @ac_session.ac_session_attributes
    @ac_session_attributes = {}
    @ac_session.user.attributes.each do |k, v|
      @ac_session_attributes['$' + k] = v
    end

    @attributes.each do |att|
      @ac_session_attributes[att.name] = att.value
    end

    doc_xml = nil
    orig_doc_xml = JSON.parse(@ac_session.ac_creator_template.document_spec_xml)

    @elements_to_layer = {}
    orig_doc_xml['elements'].each do |element_name, el|
      @elements_to_layer[element_name] = { 'id' => el['layer'], 'name' => orig_doc_xml['layer_names'][el['layer']] }
    end

    o_width = ((orig_doc_xml['size']['width'].to_f) / 72.0).to_f
    o_height = ((orig_doc_xml['size']['height'].to_f) / 72.0).to_f
    resize_factor = 0.15
    @resize = {
      'min_width'  => format('%.2f', (o_width * (1.0 - resize_factor))),
      'max_width'  => format('%.2f', (o_width * (1.0 + resize_factor))),
      'min_height' => format('%.2f', (o_height * (1.0 - resize_factor))),
      'max_height' => format('%.2f', (o_height * (1.0 + resize_factor)))
    }

    if parse_wysiwyg_data
      # logger.debug 'text_areas: ' + text_areas.inspect
      doc_attr = { 'fonts' => orig_doc_xml['fonts'], 'colors' => orig_doc_xml['colors'] }
      orig_doc_xml['elements'].each do |element_name, el|
        if text_areas[element_name]
          logger.debug 'wysiwyg: ' + element_name
          @wysiwyg_data[element_name] = generate_wysiwyg_html(el, doc_attr, @current_user.superuser?)
        end
      end
    end

    if @ac_session.ready?
      if @ac_session.current_ac_document_id
        current_ac_document = AcDocument.find(@ac_session.current_ac_document_id)
        # logger.debug 'current_ac_document.document_spec_xml found' + current_ac_document.document_spec_xml.to_s
        doc_xml = JSON.parse(current_ac_document.document_spec_xml)
      else
        # logger.debug 'session not ready'
        # doc_xml = Hash.from_xml(@ac_session.ac_creator_template.document_spec_xml)
        doc_xml = orig_doc_xml
      end
      @ac_session_attributes['resize_height'] = format('%.2f', ((doc_xml['size']['height'].to_f) / 72.0))
      @ac_session_attributes['resize_width']  = format('%.2f', ((doc_xml['size']['width'].to_f) / 72.0))
    end

    @element_scales = element_scales(doc_xml['elements']) if doc_xml.present?

    access_levels = @current_user.permissions
    language_id = current_language
    languages = Language.where(name: language_id)

    access_language_accessible = KeywordTerm.all
    if access_levels.count > 0
      if languages.count > 0
        access_language_accessible = access_language_accessible.where(language_id: languages.first.id, access_level_id: access_levels.pluck(:id))
        @filter_criteria_met = true
      else
        access_language_accessible = access_language_accessible.where(language_id: nil, access_level_id: access_levels.pluck(:id))
        @filter_criteria_met = true
      end
    else
      if languages.count > 0
        access_language_accessible = access_language_accessible.where(language_id: languages.first.id, access_level_id: nil)
        @filter_criteria_met = true
      else
        access_language_accessible = access_language_accessible.where(language_id: nil, access_level_id: nil)
        @filter_criteria_met = true
      end
    end

    @ac_image_filters = [[t('__filter_results__'), '']]
    # @ac_image_filters.concat KeywordTerm.ac_image_filter.where(keyword_term_where).pluck(:term, 'lower(term)')
    @ac_image_filters.concat access_language_accessible.ac_image_filter.pluck(:term, 'lower(term)')
    @logo_categories = [[t('__filter_results__'), '']]
    # logo_top = KeywordTerm.media_type.where('term = \'Logos\' AND' + keyword_term_where)
    logo_top = access_language_accessible.media_type.where(term: 'Logos')
    @logo_categories.concat logo_top.first.sub_terms.pluck(:term, 'lower(term)') if logo_top.length > 0

    @system_contacts = system_contacts_user.contacts
    @user_contacts = current_user.contacts

    render partial: 'workspace', content_type: 'text/html'
  end

  def render_export(export_type)
    @ac_export = @ac_session.current_ac_session_history.ac_exports.order(id: :asc).last
    if @ac_export.approval_required?
      send_approval_emails
      return render partial: 'export_approval', content_type: 'text/html'
    end
    case export_type
    when 'order'
      return render partial: 'export_order', content_type: 'text/html'
    when 'order_vista'
      return render partial: 'export_order_vista', content_type: 'text/html'
    when 'download', 'email', 'email_when_ready'
      # email address?
      # if so render export_email
      @recipient_email_address = @ac_session.current_ac_session_history.ac_exports.first.email_address
      if @recipient_email_address && @recipient_email_address != ''
        # logger.debug "email_address found: >" + @recipient_email_address + "<"
        return render partial: 'export_email', content_type: 'text/html'
      else
        return render partial: 'export_download', content_type: 'text/html'
      end
    when 'email_list'
      return render partial: 'export_email_list', content_type: 'text/html'
    else
      return render partial: 'export_download', content_type: 'text/html'
    end
  end

  def send_approval_emails
    return unless @ac_session.ready?
    oq = OperationQueue.find_or_create_by(operable_type: 'AcExport', operable_id: @ac_export.id, operation: 'approve_document', operation_type: '', queue_type: 'approve_document', status: 'ready', path: '', alt_path: '')
    logger.debug 'send_approval_emails operation queue: ' + oq.to_yaml
    UserMailer.ac_export_approval_notification_email_approver(@ac_export, current_language).deliver
    UserMailer.ac_export_approval_notification_email_user(@ac_export, 'submitted', '', current_language).deliver
  end

  def generate_wysiwyg_html(el, doc_attr, is_superuser)
    # <p style="font-family: 'trebuchet ms';">left</p>\r\n<p style="font-family: 'trebuchet ms'; text-align: right;">right</p>\r\n
    # <p style="font-family: 'trebuchet ms'; text-align: center;">center</p>\r\n
    # <p style="font-family: 'trebuchet ms'; text-align: center;"><sup>super</sup></p>\r\n
    # <p style="font-family: 'trebuchet ms'; text-align: center;"><sub>sub</sub></p>\r\n
    # <p style="font-family: 'trebuchet ms'; text-align: center;">black</p>\r\n
    # <p style="font-family: 'trebuchet ms'; text-align: center;"><span style="color: #888888;">gray</span></p>\r\n
    # <p style="font-family: 'trebuchet ms'; text-align: center;"><span style="color: #0000ff;">blue</span></p>\r\n
    # <p style="font-family: 'trebuchet ms'; text-align: center;"><span style="color: #ff0000;">red</span></p>\r\n
    # <p style="font-family: 'trebuchet ms'; text-align: center;"><span style="color: #ffffff;">white</span></p>\r\n
    # <p style="font-family: 'trebuchet ms'; text-align: center; font-size: 12pt;"><span style="color: #000000;">12</span></p>\r\n
    # <p style="font-family: 'trebuchet ms'; text-align: center; font-size: 18pt;"><span style="color: #000000;">18</span></p>\r\n
    # <p style="font-family: 'trebuchet ms'; text-align: center; font-size: 18pt;"><span style="text-decoration: underline;"><span style="color: #000000;">underline</span></span></p>

    # stylePlain    = 0x00,
    # styleBold   = 0x01,
    # styleItalic   = 0x02,
    # styleUnderline  = 0x04,
    # styleOutline  = 0x08,
    # styleShadow   = 0x10,
    # styleCondense = 0x20,
    # styleExtend   = 0x40,
    # styleWordUnderline = 0x80, // Underline printing characters only
    # styleAll    = 0xFF

    # extStylePlain   = 0xF0, // do not change this mask
    # extStyleSuperscript = 0x01,
    # extStyleSubscript = 0x02,
    # extStyleSuperior  = 0x04,
    # extStyleInferior  = 0x08,
    # // the below bits are not part of what is considered plain
    # extStyleUpperCase = 0x10,
    # extStyleLowerCase = 0x20,
    # extStyleTitleCase = 0x40,
    # extStyleSmallCaps = 0x80,
    # extStyleCaseBits  = 0x70,
    # extStyleAll     = 0xFF
    all_texts = {}
    text_string = el['text']
    text_string = '' if text_string.to_s == '{}'
    text_array = text_string.split(/\n/)
    logger.debug 'text_array: ' + text_array.inspect
    current_index = 0
    text_array.each do |t|
      all_texts[current_index] = { 'text' => t, 'start_char' => current_index, 'sub_text' => [] }
      current_index = current_index + t.length + 1
    end

    logger.debug '= begin el: ' + "\n" + el.inspect
    logger.debug '==================> begin all_texts: ' + "\n" + all_texts.inspect

    all_texts.keys.sort.each do |t|
      last_char = t + all_texts[t]['text'].length - 1
      el['par_runs'].each do |p|
        next unless t >= p['start_char'].to_i && p['start_char'].to_i < last_char
        case p['par_align'].to_i
        when 0
          all_texts[t]['par_align'] = 'left'
        when 1
          all_texts[t]['par_align'] = 'right'
        when 2
          all_texts[t]['par_align'] = 'center'
        end
      end

      last_char = t + all_texts[t]['text'].length - 1
      logger.debug 't|last_char: ' + t.to_s + '|' + last_char.to_s
      el['char_runs'].each do |ch|
        logger.debug ch['start_char'].to_s + '-'
        # start_char needs to be less than since we need to back fill paragraph runs last man standing gets formatting.
        if t > ch['start_char'].to_i # && ch['start_char'].to_i <= last_char
          logger.debug t.to_s + ' >character run found: ' + "\n" + ch.inspect + "\n"
          all_texts[t]['font_size'] = ch['font_size']
          all_texts[t]['font_name'] = font_to_h(ch, doc_attr)
          all_texts[t]['color'] = color_to_h(ch, doc_attr)
          all_texts[t]['superior'] = false
          all_texts[t]['inferior'] = false
          all_texts[t]['underline'] = false
          case ch['extended_style'].to_i
          when 4
            all_texts[t]['superior'] = true
          when 8
            all_texts[t]['inferior'] = true
          end
          case ch['style'].to_i
          when 4
            all_texts[t]['underline'] = true
          end
        end

        # determine within range
        if t <= ch['start_char'].to_i && ch['start_char'].to_i <= last_char
          if all_texts[ch['start_char'].to_i].present?
            logger.debug t.to_s + ' +character run found: ' + "\n" + ch.inspect + "\n"
            all_texts[t]['font_size'] = ch['font_size']
            all_texts[t]['font_name'] = font_to_h(ch, doc_attr)
            all_texts[t]['color'] = color_to_h(ch, doc_attr)
            all_texts[t]['superior'] = false
            all_texts[t]['inferior'] = false
            all_texts[t]['underline'] = false
            case ch['extended_style'].to_i
            when 4
              all_texts[t]['superior'] = true
            when 8
              all_texts[t]['inferior'] = true
            end
            case ch['style'].to_i
            when 4
              all_texts[t]['underline'] = true
            end
          else
            # sub_text processing
            sub_text = {}
            sub_text['start_char'] = ch['start_char'].to_i
            sub_text['font_size'] = ch['font_size']
            sub_text['font_name'] = font_to_h(ch, doc_attr)
            sub_text['color'] = color_to_h(ch, doc_attr)
            sub_text['superior'] = false
            sub_text['inferior'] = false
            sub_text['underline'] = false
            case ch['extended_style'].to_i
            when 4
              sub_text['superior'] = true
            when 8
              sub_text['inferior'] = true
            end
            case ch['style'].to_i
            when 4
              sub_text['underline'] = true
            end
            sub_text['last_char'] = last_char
            if all_texts[t]['sub_text'].length > 0
              logger.debug " sub_text['start_char']: " + sub_text['start_char'].to_s
              # all_texts[t]['sub_text']['last_char'] = sub_text['start_char'] -1
            end
            all_texts[t]['sub_text'] << sub_text
            logger.debug ch['start_char'].to_s + ' - sub_text << ' + "\n" + sub_text.inspect + "\n"
            # logger.debug ch['start_char'].to_s + " - all_texts[ch['start_char'].to_i].present? failed" + "\n" + ch.inspect  + "\n"
          end
        else
          # logger.debug '-character run not found: ' + "\n" + ch.inspect  + "\n"
        end
      end
    end

    logger.debug '================== after all_texts: ' + "\n" + all_texts.inspect + "\n<=================="

    h_text = ''
    all_texts.keys.sort.each do |k|
      p = all_texts[k]
      p_text = ''
      logger.debug 'p: ' + "\n" + p.inspect
      # paragraph attributes
      next unless p['font_name'].present? && p['font_size'].present? && p['par_align'].present?
      p_styles = ['font-family: \'' + p['font_name']['name'].to_s + '\';']
      p_styles << 'font-size: ' + (font_size_to_h p['font_size']).to_s + ';'
      p_styles << 'text-align: ' + p['par_align'].to_s + ';'

      # span attributes
      # h_color = color_to_h(p, doc_attr)
      s_styles = []
      s_styles << 'color: #' + p['color'].to_s + ';'
      s_styles << 'text-decoration: underline;' if p['underline']
      # iterate through sub_text and calculate last_char
      logger.debug "xxx p['sub_text']s: "
      p['sub_text'].each_with_index do |s, i|
        is_first = false
        # is_last = false
        if i == 0
          logger.debug 'is first'
          is_first = true
          ### adjust p['last_char']?
          p['last_char'] = s['start_char'] - 1

        end
        if p['sub_text'][-1]['start_char'] == s['start_char']
          logger.debug 'is last'
          # is_last = true
          ### adjust p['last_char']?

        end
        if p['sub_text'].length > 1 && !is_first
          # adjust last_char for previous sub_text
          p['sub_text'][i - 1]['last_char'] = s['start_char'] - 1
        end
      end
      logger.debug 'afterloop: ' + p.inspect

      # st_text = ''
      # iterate through sub_text and embed font (size, bold, italic) information
      # p['sub_text'].each_with_index do |s,i|
      #   st_styles = []
      #   st_styles << 'color: #' + s['color'].to_s + ';'
      #   if p['underline']
      #     st_styles << "text-decoration: underline;"
      #   end
      #   # if st_styles.length > 0
      #     # logger.debug "p['text']: " + p['text']
      #     # logger.debug "p['text'].length: " + p['text'].length.to_s
      #     # logger.debug "s['start_char']..s['last_char']: " + s['start_char'].to_s  + '..' + s['last_char'].to_s
      #     # first = s['start_char'].to_i
      #     # last = s['last_char']to_i
      #     # st_text = st_text + '<span style="' + s_styles.join(' ') + '">' + p['text'][first..1] + '</span>'
      #   # end
      #   logger.debug 'st_styles: ' + st_styles.inspect
      # end

      p_text = p['text']
      # <p style="font-family: 'trebuchet ms'; text-align: center; font-size: 18pt;"><span style="text-decoration: underline;"><span style="color: #000000;">underline</span></span></p>
      logger.debug 'p_text: ' + p_text.to_s
      logger.debug 'start_char (p_text): ' + p['start_char'].to_s
      logger.debug 'last_char (p_text): ' + p['last_char'].to_s

      alt_p_text = p_text
      st_text = ''
      p['sub_text'].each_with_index do |st, i|
        st_styles = []
        st_styles << 'color: #' + st['color'].to_s + ';'
        st_styles << 'text-decoration: underline;' if st['underline']
        sub_start_char_index = st['start_char'] - p['start_char'] - 1
        # sub_last_char_index = st['last_char'] - p['last_char'] - 1
        if i == 0
          p_text_last_char = sub_start_char_index
          logger.debug 'alt p_text: ' + p_text[0..p_text_last_char]
          p_text = p_text[0..p_text_last_char]
          #   logger.debug i.to_s + ' sub_start_char_index = ' + st['start_char'].to_s + '-' + p['start_char'].to_s
          #   logger.debug i.to_s + ' sub_last_char_index = ' + st['last_char'].to_s + '-' + p['last_char'].to_s
          # elsif i > 0
          #   logger.debug i.to_s + ' sub_start_char_index = ' + st['start_char'].to_s + '-' + p['sub_text'][i-1]['start_char'].to_s
          #   logger.debug i.to_s + ' sub_last_char_index = ' + st['last_char'].to_s + '-' + p['sub_text'][i-1]['last_char'].to_s
          #   sub_start_char_index = st['start_char'] - p['sub_text'][i-1]['start_char']
          #   sub_last_char_index = st['last_char'] - p['sub_text'][i-1]['start_char']

        end
        sub_start_char_index = st['start_char'] - p['start_char']
        sub_last_char_index = st['last_char'] - p['start_char']
        logger.debug 'sub_start_char_index: ' + sub_start_char_index.to_s
        logger.debug 'sub_last_char_index: ' + sub_last_char_index.to_s
        logger.debug 'alt st_text: ' + alt_p_text[sub_start_char_index..sub_last_char_index]

        st_inner_text = add_h_tags alt_p_text[sub_start_char_index..sub_last_char_index], st

        st_text = st_text + '<span style="' + st_styles.join(' ') + '">' + st_inner_text.to_s + '</span>'
      end

      p_text = add_h_tags p_text, p
      inner_text = '<p style="' + p_styles.join(' ') + '"><span style="' + s_styles.join(' ') + '">' + p_text.to_s + '</span>' + st_text.to_s + '</p>' + "\n"
      # inner_text = ''
      # if is_superuser
      #   # inner_text = '<p style="' + p_styles.join(' ') + '"><span style="' + p_styles[0] + '"><span style="' + s_styles.join(' ') + '">' + p_text.to_s + '</span>' + st_text.to_s + '</span></p>' + "\n"
      #   inner_text = '<p style="' + p_styles.join(' ') + '"><span style="' + s_styles.join(' ') + '">' + p_text.to_s + '</span>' + st_text.to_s + '</p>' + "\n"
      # else
      #   inner_text = '<p style="' + p_styles.join(' ') + '"><span style="' + s_styles.join(' ') + '">' + p_text.to_s + '</span>' + st_text.to_s + '</p>' + "\n"
      # end
      h_text += inner_text
      logger.debug 'inner_text: ' + "\n" + inner_text + "\n"
    end

    logger.debug "==================\nh_text:\n" + h_text + "\n\n"
    h_text
  end

  def add_h_tags(text, p)
    text = '<sup>' + text + '</sup>' if p['superior']
    text = '<sub>' + text + '</sub>' if p['inferior']
    text = '<strong>' + text + '</strong>' if p['font_name']['bold']
    text = '<em>' + text + '</em>' if p['font_name']['italic']
    text
  end

  def font_to_h(ch, doc_attr)
    font = doc_attr['fonts'][ch['font_id']].to_s
    # logger.debug 'font_to_h: ' + font
    h = { 'bold' => false, 'italic' => false }
    h['bold'] = true if font =~ /Bold/
    h['italic'] = true if font =~ /Italic/
    # font_formats: "Adobe Garamond Pro=garamond;Arial=arial;Arial Narrow=arial narrow;Constantia=constantia;Georgia=georgia;Handscript=handscript;Helvetica=helvetica;Palatino=palatino;Trebuchet MS=trebuchet ms;"
    case font
    when /^Trebuchet/
      h['name'] = 'trebuchet ms'
    when /^Adobe Garamond/
      h['name'] = 'garamond'
    when /^Arial/
      h['name'] = 'arial'
    when /^Arial Narrow/
      h['name'] = 'arial narrow'
    when /^Constantia/
      h['name'] = 'constantia'
    when /^Georgia/
      h['name'] = 'georgia'
    when /^Handscript/
      h['name'] = 'handscript'
    when /^Helvetica/
      h['name'] = 'helvetica'
    when /^Palatino/
      h['name'] = 'palatino'
    else
      h['name'] = 'garamond'
    end
    h
  end

  def font_size_to_h(font_size)
    logger.debug 'font_size in: ' + font_size.to_s
    new_size = 8
    [8, 9, 10, 11, 12, 13, 14, 18, 24, 30, 36, 46].each do |size|
      new_size = size if size <= font_size.to_i
    end
    logger.debug 'font_size out: ' + new_size.to_s
    new_size = new_size.to_s + 'pt'
  end

  def color_to_h(ch, doc_attr)
    color = doc_attr['colors'][ch['text_color']]
    # logger.debug '  - color: ' + ch.inspect
    # logger.debug ch['start_char'].to_s  + '  - color: >' + color.to_s + '<'
    case ch['text_color'].to_i
    when 2
      color = 'Black'
    when 3
      color = 'White'
    end
    case color
    when 'Black'
      color = '000000'
    when '50% Gray'
      color = '888888'
    when 'Blue'
      color = '0000FF'
    when 'Red'
      color = 'FF0000'
    when 'White'
      color = 'FFFFFF'
    else
      color = '000000'
    end
    # logger.debug 'after color: >' + color.to_s + '<'
    color
  end

  def set_export_email_address
    @session = AcSession.find(params[:id])
    email_address = params[:set_email_address] || current_user.email_address
    @session.current_ac_session_history.ac_exports.each do |ex|
      # logger.debug 'set_export_email_address: ' + '('+ email_address.to_s + ')' + ex.inspect
      ex.email_address = email_address
      ex.save
    end
    render nothing: true
    # return workspace
    # return render :partial => 'export_email', :ac_session => @session,  :content_type => 'text/html'
  end

  def cleanup_html_input(text)
    return unless text.present?
    text.gsub!(/<strong><\/strong>/, ' ')
    text.gsub!(/<em><\/em>/, ' ')
    text.gsub!(/\u25cf/, "\u2022")
    text.gsub!(/<!--.*?-->/, '')
    text.gsub!(/<(!--)([\s\S]*)(--)>/, '')
    text.gsub!(/><\/span>/, '> </span>')
    text.gsub!(/><\/p>/, '> </p>')
    text
  end

  def cleanup_br_input(text)
    return unless text.present?
    text.gsub!(/<br>/, '\\n')
    text.gsub!(/<br\/>/, '\\n')
    text.gsub!(/<br \/>/, '\\n')
    text
  end

  def process_step
    @template_canvas_only = params[:template_canvas_only]
    @ac_session = AcSession.find(params[:ac_session_id])
    ac_step_id = params[:ac_step_id]

    @ac_session.lock! if APP_DOMAIN !~ /localhost/

    # validate session
    @ac_session.validate_doc_spec
    return redirect_to action: 'workspace', id: @ac_session.id unless @ac_session.valid_doc_spec?

    current_doc_spec = JSON.parse(@ac_session.document_spec_xml)

    # initialize session history + document + ac_session_attributes
    @ac_session_history = @ac_session.init_session_history(@ac_session.id, ac_step_id)

    ### END INITIALIZATION

    export_files, export_location, completion_url = process_export(ac_step_id, params, current_doc_spec)
    # remove need for return values

    option_type, option_id, text_choice_ids, kwikee_product_ids = process_attributes(ac_step_id, params)
    # remove need for return values

    process_adcreator(ac_step_id, params, export_files, export_location, current_doc_spec, completion_url, option_type, option_id, text_choice_ids, kwikee_product_ids)
  end

  def process_export(ac_step_id, params, current_doc_spec)
    export_formats = params[:export_formats]
    export_type = params[:export_type]
    export_files = []
    export_location = ''
    completion_url = ''
    if export_formats && params[:ac_step] == 'export'
      init_layer_attributes(params)
      @ac_session_history.ac_session_attributes.create(ac_step_id: params[:ac_step_id], attribute_type: 'user', name: 'export_formats', value: export_formats.join(','))
      @ac_session_history.ac_session_attributes.create(ac_step_id: params[:ac_step_id], attribute_type: 'user', name: 'bleed', value: params[:bleed]) if params[:bleed].present?
      export_email_address = params[:email_address]
      export_email_subject = params[:email_subject]
      export_email_body = params[:email_body]
      if export_type == 'download'
        # Need to clear out the email address
        export_email_address = ''
      end
      ac_document = @ac_session_history.ac_document
      ac_creator_template_name = @ac_session.ac_creator_template.name
      session_path = '/sessions/' + APP_ID + '/' + @ac_session.id.to_s + '-' + ac_document.id.to_s + '/'
      export_formats.each do |export_format|
        location = ''
        case export_format
        when 'EMAIL'
          export_files << 'export_email.email:'
          location = session_path + 'export_email.email'
          export_location = session_path + 'export.zip'
        when 'BLEED_PDF'
          # Orders will get bleed_pdf if present || pdf
          location = session_path + 'export-bleed.pdf'
          ac_document.bleed_pdf = location
          export_files << location + ':' + ac_creator_template_name + '-bleed.pdf'
          export_location = session_path + 'export.zip'
        when 'PDF'
          # standard export panel
          if params[:bleed].present? && params[:bleed].to_s == '1'
            location = session_path + 'export-bleed.pdf'
            ac_document.bleed_pdf = location
            export_files << location + ':' + ac_creator_template_name + '-bleed.pdf'
            export_location = session_path + 'export.zip'
          else
            location = session_path + 'export.pdf'
            ac_document.pdf = location
            export_files << location + ':' + ac_creator_template_name + '.pdf'
            export_location = session_path + 'export.zip'
          end
        when 'PNG', 'JPG', 'EPS'
          number_of_spreads = current_doc_spec['spreads'].length
          # for multi-page this will be a loop with a zip at the end
          (1..number_of_spreads).to_a.each do |spread_number|
            suffix = '-' + spread_number.to_s + '-' + number_of_spreads.to_s + '.' + export_format.downcase
            new_filename = ac_creator_template_name + suffix
            spread_location = session_path + 'export' + suffix
            export_files << spread_location + ':' + new_filename
            location = spread_location
            # ac_document.jpg || ac_document.png ||ac_documnet.eps
          end
          ac_document.public_send("#{export_format.downcase}=".to_sym, location)
          export_location = session_path + 'export.zip'
        else
          # logger.debug "unsupported export_format"
          next
        end

        ac_document.save
        ac_export = AcExport.new(
          ac_session_history_id: @ac_session_history.id,
          email_address: export_email_address,
          email_subject: export_email_subject,
          email_body: export_email_body,
          format: export_format,
          location: location
        )

        # session defined email_subject does not supersede supplied
        attribute_email_subject = @ac_session_history.first_ac_session_attribute('@email_subject')
        ac_export.email_subject = attribute_email_subject unless ac_export.email_subject.present?

        # force system version if not enabled at system level
        if !ENABLE_INLINE_EMAIL_SUBJECT && ac_export.inline_email? || !ENABLE_MARKETING_EMAIL_SUBJECT && ac_export.marketing_email? || !ENABLE_AC_EXPORT_EMAIL_SUBJECT && !ac_export.inline_email? && !ac_export.marketing_email?
          defined_email_subject = AcStep.find(ac_step_id).form_data('email_subject') if AcStep.find(ac_step_id).form_data('email_subject').present?
          # pull subject from step data other it was received as parameter
          ac_export.email_subject = defined_email_subject if defined_email_subject.present?
          # supersede with attribute
          ac_export.email_subject = attribute_email_subject if attribute_email_subject.present?
        end
        ac_export.save
        case export_type
        when 'order'
          completion_url = APP_DOMAIN + '/adcreator/reconcile_document?id=' + @ac_session_history.ac_document_id.to_s
        when 'email_list'
          completion_url = APP_DOMAIN + '/adcreator/export_finished?id=' + @ac_session_history.ac_document_id.to_s
          email_list = EmailList.find_by(token: params[:email_list_choice])
          if email_list.present?
            marketing_email = MarketingEmail.new(
              ac_export_id: ac_export.id,
              user_id: @ac_session.user_id,
              ac_creator_template_id: @ac_session.ac_creator_template_id,
              ac_session_history_id: @ac_session_history.id,
              location: ac_export.location,
              from_name: params[:from_name] || DEFAULT_MARKETING_EMAIL_FROM_NAME || @ac_session.user.first_name + ' ' + @ac_session.user.last_name,
              from_address: params[:from_address] || DEFAULT_MARKETING_EMAIL_FROM_ADDRESS || @ac_session.user.email_address,
              reply_to: params[:reply_to],
              subject: params[:email_subject] || ac_export.email_subject,
              status: 'processing',
              user_error_string: 'Processing',
              email_list_id: email_list.id
            )
            marketing_email.save
          end
        else
          completion_url = APP_DOMAIN + '/adcreator/export_finished?id=' + @ac_session_history.ac_document_id.to_s if export_email_address
        end
      end
    else
      # direct reconcile
      completion_url = APP_DOMAIN + '/adcreator/reconcile_document?id=' + @ac_session_history.ac_document_id.to_s if APP_DOMAIN !~ /localhost/
    end
    @ac_session_history.ac_session_attributes.create(ac_step_id: params[:ac_step_id], attribute_type: 'user', name: 'export_files', value: export_files.join(','))
    @ac_session_history.ac_session_attributes.create(ac_step_id: params[:ac_step_id], attribute_type: 'user', name: 'export_location', value: export_location)
    @ac_session_history.ac_session_attributes.create(ac_step_id: params[:ac_step_id], attribute_type: 'user', name: 'completion_url', value: completion_url)
    [export_files, export_location, completion_url]
  end

  def process_attributes(ac_step_id, params)
    # @ac_session
    # @ac_session_history
    ac_step = AcStep.find(ac_step_id)

    clear_attributes(ac_step, params)
    init_input_attributes(ac_step, params)
    init_hooks(ac_step) if ac_step.form_data('hooks')
    init_standard_user_parameter_attributes(ac_step, params)
    option_type, option_id = init_option_attributes(ac_step, params)
    kwikee_product_ids = init_multiple_attributes(ac_step, params[:kwikee_product])
    text_choice_ids = init_multiple_attributes(ac_step, params[:text_choice_multiple])
    init_layer_attributes(params)

    [option_type, option_id, text_choice_ids, kwikee_product_ids]
  end

  def process_adcreator(ac_step_id, params, export_files, export_location, current_doc_spec, completion_url, option_type, option_id, text_choice_ids, kwikee_product_ids)
    ac_step = AcStep.find(ac_step_id)

    resize = false
    export = false
    delete_one_export = []
    multiple_elements = []

    # cs creator commands, aws amazon s3 file
    cs = 'version' + "\n"
    aws = nil

    # ac_step = AcStep.find(params[:ac_step_id])
    operation = ac_step.form_data('operation')

    case operation
    when 'layer'
      # stub, nothing to do here except tell masi to create the proper thumbnail
    when 'sub_layer_selection'
      cs, aws, delete_on_export, multiple_elements = cs_sub_layer_selection(@ac_session_history, ac_step_id, current_doc_spec)
    when 'sub_layer_replace_text_choice_multiple'
      cs, aws, delete_on_export, multiple_elements = cs_sub_layer_replace_text_multiple(@ac_session_history, ac_step_id, current_doc_spec)
    when 'order_vista'
      # completion_url not necessarily set from export detection
      completion_url = APP_DOMAIN + '/adcreator/export_finished?id=' + @ac_session_history.ac_document_id.to_s
      cs = cs_export(@ac_session_history, ac_step_id, current_doc_spec)
    when 'order', 'order_or_download', 'export'
      cs = cs_export(@ac_session_history, ac_step_id, current_doc_spec)
      export = true
    when 'resize'
      cs = cs_resize(@ac_session_history, ac_step_id, current_doc_spec)
      resize = true
    when 'replace_image'
      if option_type == 'UserUploadedImage'
        cs, aws, delete_on_export, multiple_elements  = cs_replace_user_image(@ac_session_history, ac_step_id, current_doc_spec)
      else
        cs, aws, delete_on_export, multiple_elements  = cs_replace_image(@ac_session_history, ac_step_id, current_doc_spec)
      end
    when 'replace_kwikee_product'
      cs, aws, delete_on_export, multiple_elements = cs_replace_kwikee_products(@ac_session_history, ac_step_id, current_doc_spec)
    when 'replace_text'
      cs, aws, delete_on_export, multiple_elements = cs_replace_text(@ac_session_history, ac_step_id, current_doc_spec)
    when 'replace_text_multiple'
      cs, aws, delete_on_export, multiple_elements = cs_replace_text_multiple(@ac_session_history, ac_step_id, current_doc_spec)
    when 'image_upload'
      if option_type == 'UserUploadedImage'
        if params[:expire]
          return expire_image_and_session_histories(@ac_session_history, option_id)
        else
          cs, aws, delete_on_export, multiple_elements = cs_image_upload(@ac_session_history, ac_step_id, current_doc_spec)
        end
      else
        cs, aws, delete_on_export, multiple_elements = cs_replace_image(@ac_session_history, ac_step_id, current_doc_spec)
      end
    else
      logger.debug 'unsupported operation for ' + ac_step.to_yaml
    end

    init_delete_on_export_triggers(ac_step_id, delete_on_export) if delete_on_export.present?

    element_name = ac_step.form_data('element_name')
    multiple_elements << element_name if element_name.present?

    # Do we need this? __element_name__ does not exist in the wild or in creator_server_commands.
    cs.gsub!('__element_name__', element_name) if element_name.present?

    layers = []
    if current_doc_spec['layers'].present?
      current_doc_spec['layers'].each do |layer|
        next if layer['name'] == 'All Layers'
        layers << layer['name']
      end
    end

    active_layer = 'Default Layer'
    active_layer = params[:set_layer] if params[:set_layer].present?
    active_layer = current_doc_spec['layer_names'][current_doc_spec['elements'][element_name]['layer']] || 'Default Layer' if element_name.present? && current_doc_spec['elements'][element_name]['layer'].present? && current_doc_spec['layer_names'].present?
    active_layer = '' if resize

    active_layers = []
    multiple_elements.each do |e_name|
      active_layers << current_doc_spec['layer_names'][current_doc_spec['elements'][e_name]['layer']] if current_doc_spec['layer_names'][current_doc_spec['elements'][e_name]['layer']] && current_doc_spec['elements'][e_name]['layer'].present? && current_doc_spec['layer_names'].present?
    end
    # resize affects all layers and requires all previews be generated.
    active_layers = current_doc_spec['layer_names'].values if operation == 'resize'
    active_layers.uniq!

    targets = ac_step.form_data('targets')
    elements = [element_name]

    spreads_hash = {}
    elements += targets.split(',') if targets.present?
    elements += multiple_elements if multiple_elements.present?
    current_doc_spec['spreads'].each do |spread_number, spread_elements|
      elements.each do |element|
        spreads_hash[spread_number.to_i + 1] = 1 if spread_elements[element].present? || resize || export
      end
    end

    # footnotes
    footnotes = []
    @ac_session_history.footnotes.each do |footnote|
      footnotes << footnote.value
    end

    xml = process_request_xml(@ac_session_history, cs, aws, export_files.join(','), export_location, completion_url, layers, active_layer, active_layers, spreads_hash.keys, footnotes, delete_on_export)

    if APP_DOMAIN !~ /localhost/
      direct_request(@ac_session, xml, @template_canvas_only)
    else
      dispatch_request(@ac_session, xml, @template_canvas_only)
    end
  end

  def init_delete_on_export_triggers(ac_step_id, delete_on_export)
    delete_on_export.each do |element_name|
      @ac_session_history.ac_session_attributes.create(ac_step_id: ac_step_id, attribute_type: 'user', name: 'delete_on_export', value: element_name)
    end
  end

  def user_uploaded_images_ac_image
    ac_session_id = current_ac_session
    @ac_session = AcSession.find(ac_session_id)
    render partial: 'user_uploaded_images_ac_image'
  end

  def expire_image_and_session_histories
    @ac_session = AcSession.find(params[:ac_session_id])

    # logger.debug 'expire_image_and_session_histories:' + params[:option_token].to_s
    img_object = UserUploadedImage.find_by(token: params[:option_token])

    # make sure image belongs to user.
    if img_object.user_id == @ac_session.user_id
      # logger.debug "proceed and expire"
      # img_object.expire = true
      @ac_session_histories = AcSessionHistory.includes(:ac_session_attributes).where(ac_session_attributes: { attribute_type: 'user', name: 'image_upload|option_id', value: img_object.id })
      # logger.debug @ac_session_histories.count
      # logger.debug @ac_session_histories.inspect
      @ac_session_histories.each do |sess|
        sess.expired = true
        sess.save!
      end
      img_object.expired = true
      img_object.save!
    end
    redirect_to action: 'workspace', id: @ac_session.id
  end

  def get_text_choice_results
    ac_step_id = params[:ac_step_id]
    ac_session_id = params[:ac_session_id]
    ac_session_history_id = params[:ac_session_history_id]

    ac_step = AcStep.find(ac_step_id)
    # @ac_session_attributes = AcSession.find(ac_session_id).ac_session_attributes
    ac_session = AcSession.find(ac_session_id)
    @wysiwyg_data = {}
    @element_scales = element_scales(JSON.parse(ac_session.document_spec_xml)['elements'])

    @attributes = ac_session.ac_session_attributes
    @ac_session_attributes = {}
    ac_session.user.attributes.each do |k, v|
      @ac_session_attributes['$' + k] = v
    end
    # @ac_session_attributes = @ac_session.user.attributes
    # logger.debug 'ac_session_attributes====' + @ac_session_attributes.inspect

    @attributes.each do |att|
      @ac_session_attributes[att.name] = att.value
    end

    results = text_choice_search(ac_step, ac_session_id, ac_session_history_id, params)
    render partial: 'ac_text_choice_results', locals: { ac_step: ac_step, ac_step_id: ac_step_id, ac_session_id: ac_session_id, ac_session_history_id: ac_session_history_id, results: results }
  end

  def element_scales(doc_xml_elements)
    scales = {}
    doc_xml_elements.each do |name, el|
      scales[name] = 100
      scales[name] = el['h_scale'] if el['h_scale'].present?
    end
    scales
  end

  def get_text_choice_multiple_results
    ac_step_id = params[:ac_step_id]
    ac_session_id = params[:ac_session_id]
    ac_session_history_id = params[:ac_session_history_id]

    ac_step = AcStep.find(ac_step_id)
    @ac_session_attributes = AcSession.find(ac_session_id).ac_session_attributes

    results = text_choice_search(ac_step, ac_session_id, ac_session_history_id, params)
    render partial: 'ac_text_choice_multiple_results', locals: { ac_step: ac_step, ac_step_id: ac_step_id, ac_session_id: ac_session_id, ac_session_history_id: ac_session_history_id, results: results }
  end

  # travelers specific
  def get_case_study_results
    ac_session_id = params[:ac_session_id]
    ac_step_id = params[:ac_step_id]
    case_study_type = params[:case_study_type]
    case_study_attribute_names = case_study_drill_down[case_study_type].keys
    results = AcText.includes(:responds_to_attributes).where(responds_to_attributes: { name: 'case_study_type', value: case_study_type })
    case_study_attribute_names.each do |attribute_name|
      next unless results.present? # no results found no use filtering further
      next unless params[attribute_name].present?
      results &= AcText.includes(:responds_to_attributes).where(responds_to_attributes: { name: attribute_name, value: [params[attribute_name], '*'] })
    end
    render partial: 'case_study_results', locals: { ac_session_id: ac_session_id, ac_step_id: ac_step_id, results: results }
  end

  private

  def text_choice_search(ac_step, _ac_session_id, ac_session_history_id, params)
    results = ac_step.search(current_user, ac_session_history_id, params)
    results &= AcText.joins(:keywords).where("keywords.keyword_type = 'system' and keywords.term like ?", '%' + params['text_choice_keyword'].downcase.to_s + '%') if params['text_choice_keyword'].present? && results.present?
    # apply filters
    %w(text_choice_filter text_choice_sub_filter).each do |keyword|
      results &= AcText.joins(:keywords).where(keywords: { term: params[keyword], keyword_type: 'search' }) if params[keyword].present? && results.present?
    end
    results
  end

  def init_hooks(ac_step)
    ac_step.form_data('hooks').each do |hook_data|
      hook_string, hook_targets = hook_data.flatten
      hook = hook_string.dup
      hook_value = ''
      if hook.sub!(/^format_text_/, '')
        hook_value = format_text_properties.find { |x| hook.sub!(/^#{x}_/, '') }
        # hook = format_text_fill_color_headline
        # IF TRUE hook_value = fill_color hook = headline
        # IF FALSE hook_value = nil hook = format_text_fill_color_headline
        hook_value = 'format_text_' + hook_value if hook_value.present?
      end

      if hook.sub!(/^set_element_/, '')
        hook_value = set_element_properties.find { |x| hook.sub!(/^#{x}_/, '') }
        # hook = set_element_fill_ink_headline
        # IF TRUE hook_value = fill_ink hook = headline
        # IF FALSE hook_value = nil hook = set_element_fill_ink_headline
        hook_value = 'set_element_' + hook_value if hook_value.present?
      end

      next unless hook_value.present?
      hook_targets.split(',').each do |form_target|
        next unless form_target.strip.present?
        target = form_target.strip
        target.sub!(/\(\d+\)/, '') # just in case, we are using element_base_name
        name = 'hook:' + target
        attr = @ac_session_history.ac_session_attributes.new(
          ac_step_id: ac_step.id,
          name: name,
          value: hook_value
        )
        attr.save
      end
    end
  end

  def clear_attributes(ac_step, params)
    return if params[:ac_step] == 'export'
    if ac_step.form_data('clear_steps').present?
      step_names = ac_step.form_data('clear_steps').map { |word| "#{ac_step.ac_base.name}:#{word}" }
      clear_steps = @ac_session.ac_base.ac_steps.where(name: step_names).pluck(:id)
      @ac_session_history.ac_session_attributes.where(ac_step_id: clear_steps).destroy_all
      # Add cleared_step attribute
      clear_steps.each do |clear_step_id|
        @ac_session_history.ac_session_attributes.create(ac_step_id: clear_step_id, attribute_type: 'user', name: 'cleared_step', value: clear_step_id)
      end
    end

    # auto_process_step should clear all other steps that could have triggered it
    if ac_step.form_data('triggers').present?
      ac_step.form_data('triggers').each do |trigger|
        next unless trigger['type'] == 'auto_process_steps'
        step_names = trigger['data'].map { |word| "#{ac_step.ac_base.name}:#{word}" }
        clear_steps = @ac_session.ac_base.ac_steps.where(name: step_names).pluck(:id)
        @ac_session_history.ac_session_attributes.where(ac_step_id: clear_steps).destroy_all
        # Add cleared_step attribute
        clear_steps.each do |clear_step_id|
          @ac_session_history.ac_session_attributes.create(ac_step_id: clear_step_id, attribute_type: 'user', name: 'cleared_step', value: clear_step_id)
        end
      end
    end

    @ac_session_history.ac_session_attributes.create(ac_step_id: ac_step.id, attribute_type: 'user', name: 'finished_step', value: ac_step.id.to_s)
  end

  def init_input_attributes(ac_step, params)
    inputs = ac_step.inputs
    if params[:option_type] == 'AcText' && params[:option_token].present?
      text_choice = LoadAsset.load_asset(type: params[:option_type], token: params[:option_token])
      inputs = text_choice.parsed_inputs if text_choice.parsed_inputs.present?
    end

    inputs.each do |result|
      new_att_name = result['name']
      new_att_name = ac_step.id.to_s + result['name'] if new_att_name == 'text' # generic, need to prepend step_id
      new_att_value = cleanup_html_input params[result['name']]
      @ac_session_history.ac_session_attributes.create(ac_step_id: ac_step.id, attribute_type: 'user', name: new_att_name, value: new_att_value)
    end

    upload_inputs = ac_step.upload_inputs
    upload_inputs.each do |result|
      new_att_name = result['name']
      new_att_name = ac_step.id.to_s + result['name'] if new_att_name == 'text' # generic, need to prepend step_id
      new_att_value = cleanup_html_input params[result['name']]
      @ac_session_history.ac_session_attributes.create(ac_step_id: ac_step.id, attribute_type: 'user', name: new_att_name, value: new_att_value)
    end
  end

  def init_standard_user_parameter_attributes(ac_step, params)
    ac_session_attribute_standard_user_params.each do |parameter|
      next unless params[parameter]
      @ac_session_history.ac_session_attributes.create(ac_step_id: ac_step.id, attribute_type: 'user', name: parameter, value: params[parameter])
    end
  end

  def init_option_attributes(ac_step, params)
    option_type = 'AcImage'
    option_id = nil
    if params[:option_token]
      att_name = ''
      operation = ac_step.form_data('operation')
      case params[:option_type]
      when 'UserUploadedImage'
        att_name = operation + '|user-option_id'
      else
        att_name = operation + '|option_id'
      end
      option_type = params[:option_type]
      asset = LoadAsset.load_asset(type: option_type, token: params[:option_token])
      option_id = asset.id
      AcSessionAttribute.create(ac_session_history_id: @ac_session_history.id, ac_step_id: ac_step.id, attribute_type: 'user', name: 'option_type', value: asset.class.name)
      AcSessionAttribute.create(ac_session_history_id: @ac_session_history.id, ac_step_id: ac_step.id, attribute_type: 'user', name: 'option_id', value: asset.id.to_s)

      @ac_session_history.ac_session_attributes.create(ac_step_id: ac_step.id, attribute_type: 'user', name: att_name, value: option_id)
    end

    [option_type, option_id]
  end

  def init_multiple_attributes(ac_step, multiple_choices)
    return [] unless multiple_choices.present?
    choices = []
    multiple_type = ''
    multiple_choices.each_with_index do |choice, i|
      asset_type, token = choice.split('|')
      asset = LoadAsset.load_asset(type: asset_type, token: token)
      multiple_type = asset.class.name
      @ac_session_history.ac_session_attributes.create(ac_step_id: ac_step.id, attribute_type: 'user', name: 'kp:gtin:' + (i + 1).to_s, value: asset.gtin) if asset.class.name == 'KwikeeProduct'

      @ac_session_history.ac_session_attributes.create(ac_step_id: ac_step.id, attribute_type: 'user', name: asset.class.name + ':' + (i + 1).to_s, value: asset.id)

      choices << asset.id
    end
    @ac_session_history.ac_session_attributes.create(ac_step_id: ac_step.id, attribute_type: 'user', name: 'multiple_type', value: multiple_type)
    @ac_session_history.ac_session_attributes.create(ac_step_id: ac_step.id, attribute_type: 'user', name: 'multiple_ids', value: choices.join(','))

    choices_name = ''
    case multiple_type
    when 'AcText'
      choices_name = 'text_choice_ids'
    when 'KwikeeProduct'
      choices_name = 'kwikee_product_ids'
    end

    @ac_session_history.ac_session_attributes.create(ac_step_id: ac_step.id, attribute_type: 'user', name: choices_name, value: choices.join(',')) if choices_name.present?
    case ac_step.form_data('operation')
    when 'sub_layer_replace_text_choice_multiple'
      @ac_session_history.ac_session_attributes.create(ac_step_id: ac_step.id, attribute_type: 'user', name: 'sub_layer_selection', value: choices.length)
    end

    choices
  end

  def init_layer_attributes(params)
    set_active_layer = params[:layer].to_s
    set_active_layer = params[:set_layer].to_s if params[:set_layer].present?
    return unless set_active_layer.present? && @ac_session.layer_mappings.present?
    ### need to find step with layer information.
    @ac_session_history.ac_session_attributes.where(ac_step_id: @ac_session.layer_mappings['raw']['ac_step_id']).destroy_all
    if @ac_session.layer_mappings['raw'][set_active_layer].present?
      @ac_session.layer_mappings['raw'][set_active_layer].each do |layer|
        @ac_session_history.ac_session_attributes.create(ac_step_id: @ac_session.layer_mappings['raw']['ac_step_id'], attribute_type: 'user', name: 'hidden_layer', value: layer.to_s)
      end
    end
    @ac_session_history.ac_session_attributes.create(ac_step_id: @ac_session.layer_mappings['raw']['ac_step_id'], attribute_type: 'user', name: 'active_layer', value: set_active_layer.to_s)
  end

  def _reconcile_document(document_id)
    ac_document = AcDocument.find(document_id)

    # pull the xml file referenced in documents
    if ac_document.status.nil?
      ac_document.load_document_spec_xml
      ac_document.status = 'reconciled'

      ac_session = ac_document.ac_session_histories.first.ac_session
      ac_session.locked = false

      ac_session.save
      ac_document.save
    end
    ac_document
  end

  def direct_request(ac_session, xml, template_canvas_only)
    # logger.debug 'dispatch_request ac_session_attributes:' + ac_session.ac_session_attributes.inspect

    url = URI.parse(DIRECT_REQUEST_URL + '/cs.xml')

    # post request to dispatch
    request = Net::HTTP::Put.new(url.path)
    request.content_type = 'text/xml'
    request.body = xml
    response = Net::HTTP.start(url.host, url.port) { |http| http.request(request) }
    logger.debug response.to_s
    # ac_session.locked = false
    # ac_session.save
    # render :partial => 'ac_auto_refresh', locals: {:ac_session_id => ac_session.id, :uuid => ac_session.uuid}

    respond_to do |format|
      # if @session.save
      format.html { redirect_to action: 'workspace', id: ac_session.id, uuid: ac_session.uuid, template_canvas_only: template_canvas_only }
      # format.html { redirect_to @session, notice: 'Process Step called.' }
      format.json { render json: ac_session, status: :created, location: ac_session }
      # else
      #   format.html { render action: "new" }
      #   format.json { render json: @session.errors, status: :unprocessable_entity }
      # end
    end
  end

  def dispatch_request(ac_session, xml, template_canvas_only)
    # logger.debug 'dispatch_request ac_session_attributes:' + ac_session.ac_session_attributes.inspect

    url = URI.parse(DISPATCH_URL)

    # post request to dispatch
    request = Net::HTTP::Post.new(url.path)
    request.content_type = 'text/xml'
    request.body = xml
    response = Net::HTTP.start(url.host, url.port) { |http| http.request(request) }
    logger.debug response.to_s
    # ac_session.locked = false
    # ac_session.save
    # render :partial => 'ac_auto_refresh', locals: {:ac_session_id => ac_session.id, :uuid => ac_session.uuid}
    respond_to do |format|
      # if @session.save
      format.html { redirect_to action: 'workspace', id: ac_session.id, uuid: ac_session.uuid, template_canvas_only: template_canvas_only }
      # format.html { redirect_to @session, notice: 'Process Step called.' }
      format.json { render json: ac_session, status: :created, location: ac_session }
      # else
      #   format.html { render action: "new" }
      #   format.json { render json: @session.errors, status: :unprocessable_entity }
      # end
    end
  end

  def process_request_xml(ac_session_history, cs, aws, export_files, export_location, completion_url, layers, active_layer, active_layers, spreads, footnotes, delete_on_export)
    # logger.debug 'aws raw' + aws.to_s + "\n"
    # logger.debug 'aws xml' + aws.to_s.encode(:xml => :text) + "\n"
    # logger.debug 'export_files xml' + export_files.to_s.encode(:xml => :text) + "\n"
    # logger.debug 'export_location' + export_location.to_s.encode(:xml => :text) + "\n"
    # logger.debug 'completion_url' + completion_url.to_s.encode(:xml => :text) + "\n"
    # cs commands cannot be null for dispatch
    email_export = export_files.match(/export_email\.email/)
    if email_export.present?
      export_files = email_export.pre_match
      email_export = 'export_email.email'
    end

    cs = 'version\n' + "\n" if cs.nil?
    xml = {}
    xml['session_id'] = ac_session_history.ac_session_id.to_s
    xml['app_id'] = APP_ID
    xml['build_name'] = CS_BUILD_NAME
    xml['build_location'] = CS_BUILD_LOCATION
    xml['completion_url'] = completion_url
    xml['secure_base_url'] = SECURE_BASE_URL
    xml['session_history_id'] = ac_session_history.id.to_s
    xml['document_id'] = ac_session_history.ac_document_id.to_s
    xml['current_document_id'] = ac_session_history.previous_ac_document_id.to_s
    xml['creator_template_id'] = ac_session_history.ac_session.ac_creator_template_id.to_s
    xml['load_session_id'] = ''
    xml['load_document_id'] = ''
    xml['export_files'] = export_files
    xml['export_location'] = export_location
    xml['aws'] = aws || ''
    xml['footnotes'] = footnotes
    xml['delete_on_export'] = delete_on_export

    layer_commands = ''
    layers.each do |layer|
      layer_commands += 'set visible layer named "' + layer + '" of document 1 to false' + "\n"
    end
    layer_commands += 'set visible layer named "' + active_layer + '" of document 1 to true' + "\n"

    xml['layers'] = layer_commands.to_s

    # spreads
    # ---> elements

    xml['spreads'] = spreads.join(',').to_s
    xml['active_layer'] = active_layer.to_s
    xml['active_layers'] = active_layers
    xml['hidden_layers'] = ac_session_history.ac_session.hidden_layers['names']
    if export_location.present?
      xml['after_save_commands'] = cs.to_s
    else
      xml['commands'] = cs.to_s
    end
    if email_export.present?
      # email id
      xml['email_id'] = ac_session_history.ac_session.ac_creator_template_id.to_s
      # email_images
      email_images = []
      ac_session_history.ac_session.ac_base.graphic_containers.each do |element_name, _element_spec|
        # cs += 'export ' +  element_spec + ' as PNG "__output_path__export_email-' + element_name + '.jpg" resolution 100dpi ' +  "\n"
        email_images << element_name.to_s
      end
      xml['email_images'] = email_images if email_images.present?

      xml['email_variables'] = ac_session_history.email_text_replacements
      # opt_out_link
      locals = binding
      locals.local_variable_set(:marketing_email_opt_out_url, marketing_email_opt_out_url)
      locals.local_variable_set(:marketing_email_opt_out_link, t('marketing_email_opt_out_message', app_name_long: APP_NAME_LONG))
      opt_out_html = ERB.new(File.read('app/views/marketing_emails/_opt_out_link.html.erb'))
      logger.debug 'opt_out_html.result ' + opt_out_html.result(locals)
      xml['email_variables'] << { 'name' => 'opt_out_link', 'value' => opt_out_html.result(locals) }
    end

    xml_string = xml.to_xml(root: 'xml', dasherize: false)
    logger.debug "\n\n" + xml_string + "\n\n"

    xml_string
  end

  def update_ac_session(ac_session_id)
    @ac_session = AcSession.find(ac_session_id)
    if @ac_session.locked
      ### return without processing
      logger.debug '@ac_session.locked'
    elsif @ac_session.current_ac_session_history_id
      # get status make sure it is complete? change to reconciled?
      # url = URI.parse( STATUS_URL )
      # logger.debug url.inspect
      current_ac_session_history = AcSessionHistory.find(@ac_session.current_ac_session_history_id)
      ac_document = current_ac_session_history.ac_document
      update_session_dispatch(ac_document) if ac_document.status.nil? && APP_DOMAIN.match(/localhost/)
      ### prevent endless spin for direct request?  would need js to pickup this logic
    else
      # should not have been called
      logger.debug 'no current document update_session should not have been called'
    end
    @ac_session
  end

  def update_session_dispatch(ac_document)
    # post request to dispatch
    # res = Net::HTTP.post_form(STATUS_URL, 'session_id' => @session.id, 'session_history_id' => @session.current_session_history_id)
    uri = URI(STATUS_URL + '.xml?app_id=' + APP_ID + '&session_id=' + @ac_session.id.to_s + '&session_history_id=' + @ac_session.current_ac_session_history_id.to_s)
    response = Net::HTTP.get_response(uri)
    # logger.debug response.code.to_s
    # logger.debug '========================================================================================'
    # logger.debug response.code.to_s
    case response
    when Net::HTTPSuccess
      xml = Hash.from_xml(response.body)
      # if complete, do the following
      if xml['request']['status'] == 'complete'
        # set thumbnail and preview image in documents
        # set status to reconciled
        url = STATUS_URL + '?app_id=' + APP_ID + '&session_id=' + @ac_session.id.to_s + '&session_history_id=' + @ac_session.current_ac_session_history_id.to_s + '&status=reconciled'
        uri = URI(url)
        status_response = Net::HTTP.get(uri)
        logger.debug status_response.to_s
        # pull the xml file referenced in documents
        xml_uri = URI(AC_BASE_URL + ac_document.document_spec_xml)
        xml_response = Net::HTTP.get(xml_uri)
        # logger.debug xml_response
        # logger.debug '========================================================================================'
        ac_document.document_spec_xml = xml_response
        if @ac_session.ac_creator_template.document_spec_xml.empty?
          # logger.debug 'setting ac_creator_template.document_spec_xml'
          @ac_session.ac_creator_template.document_spec_xml = xml_response
          @ac_session.ac_creator_template.save
        end
        ac_document.status = 'reconciled'
        ac_document.save
      end
    else
      logger.debug 'update_session_dispatch session xml failed'
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_ac_session
    @ac_session = AcSession.find(params[:id])
  end

  def ac_session_attribute_standard_user_params
    %w(export_type quantity resize_width resize_height resize_top resize_bottom resize_left resize_right sub_layer_selection)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ac_session_params
    params.require(:ac_session).permit(:user_id, :ac_creator_template_id, :ac_base_id)
  end
end
