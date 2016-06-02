class DlImagesController < ApplicationController
  before_action :set_dl_image, only: [:show, :edit, :update, :destroy]
  before_action :contributor?, only: [:admin_processing, :admin_dl_image_publish, :admin_cancel]
  before_action :superuser?, only: [:index, :show, :new, :edit, :create, :update, :destroy]

  def admin_dl_image
    case params[:display]
    when 'staged'
      @staged_dl_images = DlImage.where(status: 'staged')
    when 'unstaged'
      @unstaged_dl_images = DlImage.where(status: 'unstaged')
    when 'processed'
      @processed_dl_images = DlImage.where(status: 'processed')
    when 'production'
      @production_dl_images = DlImage.where(status: 'production')
    when 'unpublished'
      @unpublished_dl_images = DlImage.where(status: 'unpublished')
    else
      @staged_dl_images = DlImage.where(status: 'staged')
    end

    @uploader = DlImage.new.bundle
    @uploader.success_action_redirect = url_for controller: 'dl_images', action: 'admin_upload_direct_bundle'

    render 'admin_dl_image'
  end

  # 1) upload form
  def admin_dl_image_upload
    # refresh form
    @uploader = DlImage.new.bundle
    @uploader.success_action_redirect = url_for controller: 'dl_images', action: 'admin_upload_direct_bundle'
    render partial: 'admin_dl_image_upload'
  end

  # 2) carrierwave direct callback
  def admin_upload_direct_bundle
    logger.debug "\n\n DlImage admin_upload_direct_bundle started \n\n"

    params
    @dl_image = DlImage.create(upload_params)
    @dl_image.save!
    logger.debug @dl_image.inspect

    filename = @dl_image.bundle.path
    @dl_image.filename = filename.gsub(/.*\//, '')
    @dl_image.status = 'uploaded'
    @dl_image.save
    logger.debug @dl_image.inspect

    logger.debug "\n\n DlImage admin_upload_direct_bundle finished \n\n"
    redirect_to admin_dl_image_edit_url + '?token=' + @dl_image.token.to_s
  end

  # 3) name, title form
  def admin_edit_dl_image
    token = params[:token]
    logger.debug "\n\n admin_edit_dl_image started \n\n"
    @dl_image = DlImage.find_by(token: token)
    logger.debug "\n\n admin_edit_dl_image finished \n\n"
    render 'admin_edit_dl_image'
  end

  # 4) load to server
  def admin_load_dl_image
    token = params[:token]
    @dl_image = DlImage.find_by(token: token)
    logger.debug "\n\n admin_load_dl_image started \n\n"

    @dl_image.name =  params[:name]
    @dl_image.title =  params[:title]
    @dl_image.save!

    # send setup xml to MASI
    xml = admin_dl_image_xml(@dl_image)
    dispatch_dl_image_request(xml)

    logger.debug "\n\n admin_load_dl_image finished \n\n"
    redirect_to admin_dl_image_url
  end

  # 5) callback: mark as staged from server
  def admin_dl_image_staged
    token = params[:token]
    location = params[:location]
    no_preview = params[:no_preview]
    dl_image = DlImage.find_by(token: token)
    dl_image.status = 'staged'
    unless no_preview
      dl_image.thumbnail = '/dl_images/' + APP_ID + '/' + dl_image.id.to_s + '/thumbnail_' + dl_image.id.to_s + '.png'
      dl_image.preview = '/dl_images/' + APP_ID + '/' + dl_image.id.to_s + '/preview.png'
    end
    dl_image.location = '/dl_images/' + APP_ID + '/' + dl_image.id.to_s + '/' + location.to_s
    dl_image.save!

    render nothing: true
  end

  # 6) dl_image display
  def admin_dl_image_display

    @dl_image = DlImage.where(token: params[:token]).first

    ### Keyword
    @loaded_keywords = Hash.new
    @keyword_types = KeywordType.all.pluck(:name)

    @keyword_types.each do |kt|
      @loaded_keywords[kt] = Array.new
    end

    @dl_image.keywords.each do |k|
      next if k.keyword_type.match(/^(pre-|unpublished-)*system$/)
      next if k.keyword_type.match(/^(pre-|unpublished-)*category$/)
      keyword_type = k.keyword_type.sub(/^(pre-|unpublished-)/,'')
      @loaded_keywords[keyword_type].push k.term
    end

    render 'admin_dl_image_display'
  end

  # 7) dl_image save
  def admin_dl_image_save
    token = params[:token]

    dl_image = DlImage.where(token: token).first

    current_keywords = Keyword.where(searchable_type: 'DlImage', searchable_id: dl_image.id)
    current_keywords.each(&:destroy)

    # collect keywords for processing
    keywords = {}
    keyword_types = KeywordType.all.pluck(:name)
    keyword_types.each do |keyword_type|
      keywords['pre-' + keyword_type] = params['pre-' + keyword_type].split(',').uniq - ['', ' ', nil]
    end

    ## add category
    keywords['pre-category'] = ['asset-library']
    # append default keywords

    keywords['pre-system'] = [dl_image.name.downcase, dl_image.title.downcase]

    keywords.each do |keyword_type, keywords_array|
      keywords_array.uniq.each do |k|
        k = k.strip
        keyword_hash = { searchable_type: 'DlImage', searchable_id: dl_image.id, keyword_type: keyword_type }
        keyword_hash['term'] = k.downcase
        k = Keyword.new(keyword_hash)
        k.save!
      end
    end

    dl_image.status = 'processed'
    dl_image.save

    redirect_to admin_dl_image_url + '?display=processed'
  end

  # contributor functions
  def admin_dl_image_publish
    token = params[:token]
    status = params[:status]
    if token && status
      dl_image = DlImage.find_by(token: token)
      ### safety net restrict operation to
      if dl_image.user_id == current_user.id && current_user.contributor? || current_user.admin? || current_user.superuser?

        case status
        when 'unstaged'
          keywords = Keyword.where(searchable_type: 'DlImage', searchable_id: dl_image.id)
          keywords.each(&:destroy)
        when 'staged'
          # Not implemented, this is set when uploaded and keywords do not exist.
        when 'production'
          dl_image.republish!
        when 'unpublished'
          keywords = Keyword.where(searchable_type: 'DlImage', searchable_id: dl_image.id)
          keywords.each do |k|
            case k.keyword_type
            when 'category'
              k.keyword_type = 'unpublished-category'
            when 'system'
              k.keyword_type = 'unpublished-system'
            when 'search'
              k.keyword_type = 'unpublished-search'
            when 'media_type'
              k.keyword_type = 'unpublished-media_type'
            when 'topic'
              k.keyword_type = 'unpublished-topic'
            end
            k.save
          end
          dl_image.expire!
        end
        dl_image.status = status
        dl_image.save
      end
    end
    render nothing: true, status: 200, content_type: 'text/html'

    # redirect_to admin_dl_image_url
  end

  def admin_processing
    dl_images = current_user.dl_images.incomplete
    user_upload_requests = current_user.user_upload_requests.dl_image.incomplete

    # logger.debug dl_images.inspect
    render partial: 'processing',  locals: { dl_images: dl_images, user_upload_requests: user_upload_requests }
  end

  def admin_cancel
    image = DlImage.find_by(token: params[:token])
    image.expire! if image.user == current_user || current_user.admin? || current_user.superuser?

    head :ok
  end

  def upload_form
    render json: DlImage.new.bundle.upload_form_data(params[:legacy])
  end

  def incomplete
    render json: current_user.dl_images.incomplete
  end

  def poll
    render json: current_user.dl_images.unscoped.where(token: params[:tokens])
  end

  def upload_direct_contributor
    dl_image = DlImage.create!(key: params[:key], user: current_user)

    render json: dl_image
  end

  # GET /dl_images
  # GET /dl_images.json
  def index
    @dl_images = DlImage.all
  end

  # GET /dl_images/1
  # GET /dl_images/1.json
  def show
  end

  # GET /dl_images/new
  def new
    @dl_image = DlImage.new
  end

  # GET /dl_images/1/edit
  def edit
  end

  # POST /dl_images
  # POST /dl_images.json
  def create
    @dl_image = DlImage.new(dl_image_params)

    respond_to do |format|
      if @dl_image.save
        @dl_image.update_responds_to_attributes params['responds_to_attribute_list'] if params['responds_to_attribute_list'].present?
        @dl_image.update_set_attributes params['set_attribute_list'] if params['set_attribute_list'].present?
        format.html { redirect_to @dl_image, notice: 'Dl image was successfully created.' }
        format.json { render action: 'show', status: :created, location: @dl_image }
      else
        format.html { render action: 'new' }
        format.json { render json: @dl_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dl_images/1
  # PATCH/PUT /dl_images/1.json
  def update
    respond_to do |format|
      if @dl_image.update(dl_image_params)
        @dl_image.update_responds_to_attributes params['responds_to_attribute_list'] if params['responds_to_attribute_list'].present?
        @dl_image.update_set_attributes params['set_attribute_list'] if params['set_attribute_list'].present?
        format.html { redirect_to @dl_image, notice: 'Dl image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dl_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dl_images/1
  # DELETE /dl_images/1.json
  def destroy
    @dl_image.destroy
    respond_to do |format|
      format.html { redirect_to dl_images_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dl_image
    @dl_image = DlImage.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dl_image_params
    params.require(:dl_image).permit(:name, :title, :location, :preview, :thumbnail, :folder, :filename, :token, :s3_key, :uploaded, :status, :job_id, :publish_at, :unpublish_at)
  end
end
