class AcImagesController < ApplicationController
  before_action :set_ac_image, only: [:show, :edit, :update, :destroy]
  before_action :superuser?, except: [:admin_upload_direct_ac_image, :admin_upload_direct_bundle, :admin_ac_image_staged, :admin_processing, :admin_add_to_library, :admin_ac_image_publish, :admin_cancel]

  def admin_ac_image
    case params[:display]
    when 'staged'
      @staged_ac_images = AcImage.where(status: 'staged')
    when 'unstaged'
      @unstaged_ac_images = AcImage.where(status: 'unstaged')
    when 'processed'
      @processed_ac_images = AcImage.where(status: 'processed')
    when 'production'
      @production_ac_images = AcImage.where(status: 'production')
    when 'unpublished'
      @unpublished_ac_images = AcImage.where(status: 'unpublished')
    else
      @staged_ac_images = AcImage.where(status: 'staged')
    end

    @uploader = AcImage.new.bundle
    @uploader.use_action_status = false
    @uploader.success_action_redirect = url_for controller: 'ac_images', action: 'admin_upload_direct_bundle'

    render 'admin_ac_image'
  end

  # 1) upload form
  def admin_ac_image_upload
    #refresh form
    @uploader = AcImage.new.bundle
    @uploader.success_action_redirect = url_for controller: 'ac_images', action: 'admin_upload_direct_bundle'
    render partial: 'admin_ac_image_upload'
  end

  # 2) carrierwave direct callback
  def admin_upload_direct_bundle
    logger.debug "\n\n AcImage admin_upload_direct_bundle started \n\n"

    params
    @ac_image = AcImage.create(upload_params)
    @ac_image.save!
    logger.debug @ac_image.inspect

    filename = @ac_image.bundle.path
    @ac_image.filename = filename.gsub(/.*\//, '')
    @ac_image.status = 'uploaded'
    @ac_image.save
    logger.debug @ac_image.inspect
    @ac_image

    logger.debug "\n\n AcImage admin_upload_direct_bundle finished \n\n"
    redirect_to admin_ac_image_edit_url + '?token=' + @ac_image.token.to_s
  end

  # 3) name, title form
  def admin_edit_ac_image
    token = params[:token]
    logger.debug "\n\n admin_edit_ac_image started \n\n"
    @ac_image = AcImage.find_by(token: token)
    logger.debug "\n\n admin_edit_ac_image finished \n\n"
    render 'admin_edit_ac_image'
  end

  # 4) load to server
  def admin_load_ac_image
    token = params[:token]
    @ac_image = AcImage.find_by(token: token)
    logger.debug "\n\n admin_load_ac_image started \n\n"

    @ac_image.name =  params[:name];
    @ac_image.title =  params[:title];
    @ac_image.save!

    # send setup xml to MASI
    xml = admin_ac_image_xml(@ac_image)
    dispatch_ac_image_request(xml)

    logger.debug "\n\n admin_load_ac_image finished \n\n"
    redirect_to admin_ac_image_url
  end

  # 5) callback: mark as staged from server
  def admin_ac_image_staged
    token = params[:token]
    location = params[:location]
    ac_image = AcImage.find_by(token: token)
    ac_image.status = 'staged'
    ac_image.thumbnail = '/ac_images/' + APP_ID + '/' + ac_image.id.to_s + '/thumbnail_' + ac_image.id.to_s + '.png'
    ac_image.preview = '/ac_images/' + APP_ID + '/' + ac_image.id.to_s + '/preview_' + ac_image.id.to_s + '.png'
    ac_image.location = '/ac_images/' + APP_ID + '/' + ac_image.id.to_s + '/' + location.to_s
    ac_image.save!

    render nothing: true
  end

  # 6) ac_image display
  def admin_ac_image_display
    @ac_image = AcImage.where(token: params[:token]).first
    init_flag = params[:init]

    ### Keyword
    @loaded_keywords = {}
    @keyword_types = KeywordType.all.pluck(:name)

    @keyword_types.each do |kt|
      @loaded_keywords[kt] = []
    end

    @ac_image.keywords.each do |k|
      next if k.keyword_type.match(/^(pre-)*system$/)
      next if k.keyword_type.match(/^(pre-)*category$/)
      keyword_type = k.keyword_type.sub(/^pre-/, '')
      @loaded_keywords[keyword_type].push k.term
    end

    render 'admin_ac_image_display'
  end

  # 7) ac_image save
  def admin_ac_image_save
    token = params[:token]
    # keywords = { 'pre-search' => params[:keywords] }

    ac_image = AcImage.where(token: token).first

    current_keywords = Keyword.where(searchable_type: 'AcImage', searchable_id: ac_image.id)
    current_keywords.each do |k|
      k.destroy
    end

    # collect keywords for processing
    keywords = {}
    keyword_types = KeywordType.all.pluck(:name)
    keyword_types.each do |keyword_type|
      keywords['pre-' + keyword_type] = params['pre-' + keyword_type].split(',').uniq - ['', ' ', nil]
    end

    keywords.each do |keyword_type, keywords_array|    # keywords.each do |keyword_type, keyword_terms|
      # keywords_array = keyword_terms.split(',') - ['',' ',nil]
      keywords_array.uniq.each do |k|
        k = k.strip
        keyword_hash = { searchable_type: 'AcImage', searchable_id: ac_image.id, keyword_type: keyword_type }
        keyword_hash['term'] = k.downcase
        k = Keyword.new(keyword_hash)
        k.save!
      end
    end

    ac_image.status = 'processed'
    ac_image.save

    redirect_to admin_ac_image_url + '?display=processed'
  end

  def admin_ac_image_publish
    token = params[:token]
    status = params[:status]
    if token && status
      ac_image = AcImage.find_by(token: token)
      case status
      when 'unstaged'
        keywords = Keyword.where(searchable_type: 'AcImage', searchable_id: ac_image.id)
        keywords.each do |k|
          k.destroy
        end
      when 'staged'
        # Not implemented, this is set when uploaded and keywords do not exist.
      when 'production'
        keywords = Keyword.where(searchable_type: 'AcImage', searchable_id: ac_image.id)
        keywords.each do |k|
          case k.keyword_type
          when 'pre-category'
            k.keyword_type = 'category'
          when 'pre-search'
            k.keyword_type = 'search'
          when 'pre-system'
            k.keyword_type = 'system'
          when 'pre-media_type'
            k.keyword_type = 'media_type'
          when 'pre-topic'
            k.keyword_type = 'topic'
          end
          k.save
        end
      when 'unpublished'
        status = 'complete'
        ac_image.expired = true
      end
      ac_image.status = status
      ac_image.save
    end

    redirect_to admin_ac_image_url
  end

  def admin_processing
    ac_images = current_user.ac_images.incomplete
    user_upload_requests = current_user.user_upload_requests.admin_ac_image.incomplete

    # logger.debug ac_images.inspect
    render partial: 'processing', locals: { ac_images: ac_images, user_upload_requests: user_upload_requests }
  end

  def admin_cancel
    AcImage.find_by(token: params[:token]).expire! if current_user.admin? || current_user.superuser?

    head :ok
  end

  def admin_upload_direct_ac_image
    ac_image = AcImage.create!(key: params[:key], user: current_user)

    render json: ac_image
  end

  def poll
    render json: AcImage.unscoped.where(tokens: params[:tokens])
  end

  def incomplete
    render json: current_user.ac_images.incomplete
  end

  def upload_form
    render json: AcImage.new.bundle.upload_form_data(params[:legacy])
  end

  # GET /ac_images
  # GET /ac_images.json
  def index
    @ac_images = AcImage.all
  end

  # GET /ac_images/1
  # GET /ac_images/1.json
  def show
  end

  # GET /ac_images/new
  def new
    @ac_image = AcImage.new
  end

  # GET /ac_images/1/edit
  def edit
  end

  # POST /ac_images
  # POST /ac_images.json
  def create
    @ac_image = AcImage.new(ac_image_params)

    respond_to do |format|
      if @ac_image.save
        @ac_image.update_responds_to_attributes params['responds_to_attribute_list'] if params['responds_to_attribute_list'].present?
        @ac_image.update_set_attributes params['set_attribute_list'] if params['set_attribute_list'].present?
        format.html { redirect_to @ac_image, notice: 'Ac image was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ac_image }
      else
        format.html { render action: 'new' }
        format.json { render json: @ac_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ac_images/1
  # PATCH/PUT /ac_images/1.json
  def update
    respond_to do |format|
      if @ac_image.update(ac_image_params)
        @ac_image.update_responds_to_attributes params['responds_to_attribute_list'] if params['responds_to_attribute_list'].present?
        @ac_image.update_set_attributes params['set_attribute_list'] if params['set_attribute_list'].present?
        format.html { redirect_to @ac_image, notice: 'Ac image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ac_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ac_images/1
  # DELETE /ac_images/1.json
  def destroy
    @ac_image.destroy
    respond_to do |format|
      format.html { redirect_to ac_images_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ac_image
    @ac_image = AcImage.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ac_image_params
    params.require(:ac_image).permit(:name, :title, :thumbnail, :preview, :location, :folder, :filename, :expired, :status, :token, :publish_at, :unpublish_at)
  end

  def upload_params
    params.permit(:key)
  end
end
