class UserUploadedImagesController < ApplicationController
  before_action :set_user_uploaded_image, only: [:destroy]
  before_action :logged_in?
  before_action :admin?, only: [:index, :show, :new, :edit, :create, :update, :destroy]

  def upload_form
    render json: UserUploadedImage.new.image_upload.upload_form_data(params[:legacy])
  end

  def upload_direct_library
    create_params = {
      key:  params[:key],
      user: current_user
    }

    # due to extension whitelist on uploader, else block is impossible...
    extension = File.extname(params[:key]).gsub(/^\./, '').downcase
    if Rails.configuration.image_extensions.include? extension
      create_params[:upload_type] = 'library_image'
    elsif Rails.configuration.video_extensions.include? extension
      create_params[:upload_type] = 'library_video'
    else
      create_params[:upload_type] = 'library_file'
      create_params[:is_shareable_via_social_media] = false
      logger.warn "failed to determine asset type for extension #{extension}"
    end

    image = UserUploadedImage.create!(create_params)

    render json: image
  end

  def upload_direct_logo
    create_params = {
      key:  params[:key],
      user: current_user
    }

    # doesn't else block indicate an error condition and we should raise an exception?
    extension = File.extname(params[:key]).gsub(/^\./, '').downcase
    if Rails.configuration.ac_image_extensions.include?(extension)
      create_params[:upload_type] = 'logo'
    else
      # must strictly validate against what creator is compatible with, so this is appropriate, right?
      return head :unprocessable_entity
    end

    user_uploaded_image = UserUploadedImage.create!(create_params)

    render json: user_uploaded_image
  end

  def upload_direct_attachment
    create_params = {
      key:  params[:key],
      user: current_user
    }

    create_params[:upload_type] = 'attachment'
    create_params[:status] = 'complete'

    user_uploaded_image = UserUploadedImage.create!(create_params)

    render json: user_uploaded_image
  end

  def upload_direct_ac_image
    create_params = {
      key:  params[:key],
      user: current_user
    }

    # doesn't else block indicate an error condition and we should raise an exception?
    extension = File.extname(params[:key]).gsub(/^\./, '').downcase
    if Rails.configuration.ac_image_extensions.include?(extension)
      create_params[:upload_type] = 'ac_image'
    else
      # must strictly validate against what creator is compatible with, so this is appropriate, right?
      return head :unprocessable_entity
    end

    user_uploaded_image = UserUploadedImage.create!(create_params)

    render json: user_uploaded_image
  end

  def poll
    render json: current_user.user_uploaded_images.unscoped.where(token: params[:tokens])
  end

  def incomplete
    images = current_user.user_uploaded_images.incomplete

    case params[:upload_type]
    when 'ac_image'
      images = images.where(upload_type: 'ac_image')
    when 'attachment'
      images = images.where(upload_type: 'attachment')
    when 'library'
      images = images.where("upload_type like 'library_%'")
    when 'logo'
      images = images.where(upload_type: 'logo')
    else
      raise 'unknown upload_type'
    end

    render json: images
  end

  # POST /user_uploaded_images
  def upload
    uploader = UserUploadedImage.new

    uploader.user_id = current_user.id
    uploader.image_upload = params[:image_upload]
    # uploader.image_upload = File.open('somewhere')
    uploader.save!
    logger.debug 'uploader.inspect' + uploader.inspect

    data = {}
    data['aws'] = current_user.id.to_s + '|' + uploader.id.to_s + '|' + uploader.image_upload_url
    xml = data.to_xml(root: 'xml', dasherize: false)

    direct_request(xml)

    redirect_to profile_url
  end

  # more of the same?
  def expire_logo
    current_user.user_uploaded_images.find_by(token: params[:token]).expire!
    redirect_to profile_url
  end

  def expire_library
    current_user.user_uploaded_images.find_by(token: params[:token]).expire!

    ### assumes ajax call and calling search form again via js
    head :ok
  end

  def cancel
    current_user.user_uploaded_images.find_by(token: params[:token]).expire!
    head :ok
  end

  # GET /user_uploaded_images
  # GET /user_uploaded_images.json
  def index
    @user_uploaded_images = UserUploadedImage.all
  end

  # GET /user_uploaded_images/1
  # GET /user_uploaded_images/1.json
  def show
  end

  # GET /user_uploaded_images/new
  def new
    @user_uploaded_image = UserUploadedImage.new
  end

  # GET /user_uploaded_images/1/edit
  def edit
  end

  # POST /user_uploaded_images
  # POST /user_uploaded_images.json
  def create
    @user_uploaded_image = UserUploadedImage.new(user_uploaded_image_params)

    respond_to do |format|
      if @user_uploaded_image.save
        format.html { redirect_to @user_uploaded_image, notice: 'User uploaded image was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user_uploaded_image }
      else
        format.html { render action: 'new' }
        format.json { render json: @user_uploaded_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_uploaded_images/1
  # PATCH/PUT /user_uploaded_images/1.json
  def update
    respond_to do |format|
      if @user_uploaded_image.update(user_uploaded_image_params)
        format.html { redirect_to @user_uploaded_image, notice: 'User uploaded image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user_uploaded_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_uploaded_images/1
  # DELETE /user_uploaded_images/1.json
  def destroy
    @user_uploaded_image.destroy
    respond_to do |format|
      format.html { redirect_to user_uploaded_images_url }
      format.json { head :no_content }
    end
  end

  private

  def direct_request(xml)
    url = URI.parse(SECURE_BASE_URL + '/requests/new/aws.xml')
    request = Net::HTTP::Put.new(url.path)
    request.content_type = 'text/xml'
    request.body = xml
    Net::HTTP.start(url.host, url.port) { |http| http.request(request) }
  end

  def set_user_uploaded_image
    @user_uploaded_image = UserUploadedImage.find(params[:id])
  end
end
