class UserDownloadsController < ApplicationController
  before_action :set_user_download, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?

  # GET /user_downloads
  # GET /user_downloads.json
  def index
    @user_downloads = UserDownload.all
  end

  # GET /user_downloads/1
  # GET /user_downloads/1.json
  def show
  end

  # GET /user_downloads/new
  def new
    @user_download = UserDownload.new
  end

  # GET /user_downloads/1/edit
  def edit
  end

  # POST /user_downloads
  # POST /user_downloads.json
  def create
    @user_download = UserDownload.new(user_download_params)

    respond_to do |format|
      if @user_download.save
        format.html { redirect_to @user_download, notice: 'User download was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user_download }
      else
        format.html { render action: 'new' }
        format.json { render json: @user_download.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_downloads/1
  # PATCH/PUT /user_downloads/1.json
  def update
    respond_to do |format|
      if @user_download.update(user_download_params)
        format.html { redirect_to @user_download, notice: 'User download was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user_download.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_downloads/1
  # DELETE /user_downloads/1.json
  def destroy
    @user_download.destroy
    respond_to do |format|
      format.html { redirect_to user_downloads_url }
      format.json { head :no_content }
    end
  end

  def download
    # params[:id]
    # params[:downloadable_type]
    user_id = current_user.id
    downloadable_id = params[:id]
    downloadable_type = params[:downloadable_type]

    dli = LoadAsset.load_asset(type: downloadable_type, id: downloadable_id)
    case downloadable_type
    when 'DlImage'
      ud = UserDownload.new(
        user_id:  user_id,
        downloadable_id: downloadable_id,
        downloadable_type: downloadable_type
      )
      ud.save
      redirect_to SECURE_BASE_URL + dli.location
    when 'UserUploadedImage'
      ud = UserDownload.new(
        user_id:  user_id,
        downloadable_id: downloadable_id,
        downloadable_type: downloadable_type
      )
      ud.save
      redirect_to dli.image_upload_url
    else
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_download
      @user_download = UserDownload.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_download_params
      params.require(:user_download).permit(:user_id, :dl_cart_id, :downloadable_id, :downloadable_type)
    end
end
