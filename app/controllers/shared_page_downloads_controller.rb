class SharedPageDownloadsController < ApplicationController
  before_action :set_shared_page_download, only: [:show, :edit, :update, :destroy]
  before_action :superuser?

  # GET /shared_page_downloads
  # GET /shared_page_downloads.json
  def index
    @shared_page_downloads = SharedPageDownload.all
  end

  # GET /shared_page_downloads/1
  # GET /shared_page_downloads/1.json
  def show
  end

  # GET /shared_page_downloads/new
  def new
    @shared_page_download = SharedPageDownload.new
  end

  # GET /shared_page_downloads/1/edit
  def edit
  end

  # POST /shared_page_downloads
  # POST /shared_page_downloads.json
  def create
    @shared_page_download = SharedPageDownload.new(shared_page_download_params)

    respond_to do |format|
      if @shared_page_download.save
        format.html { redirect_to @shared_page_download, notice: 'Shared page download was successfully created.' }
        format.json { render action: 'show', status: :created, location: @shared_page_download }
      else
        format.html { render action: 'new' }
        format.json { render json: @shared_page_download.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shared_page_downloads/1
  # PATCH/PUT /shared_page_downloads/1.json
  def update
    respond_to do |format|
      if @shared_page_download.update(shared_page_download_params)
        format.html { redirect_to @shared_page_download, notice: 'Shared page download was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @shared_page_download.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shared_page_downloads/1
  # DELETE /shared_page_downloads/1.json
  def destroy
    @shared_page_download.destroy
    respond_to do |format|
      format.html { redirect_to shared_page_downloads_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shared_page_download
      @shared_page_download = SharedPageDownload.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shared_page_download_params
      params.require(:shared_page_download).permit(:shared_page_id, :shareable_type, :shareable_id)
    end
end
