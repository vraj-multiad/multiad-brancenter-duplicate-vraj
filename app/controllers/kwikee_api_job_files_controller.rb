class KwikeeApiJobFilesController < ApplicationController
  before_action :set_kwikee_api_job_file, only: [:show, :edit, :update, :destroy]

  # GET /kwikee_api_job_files
  # GET /kwikee_api_job_files.json
  def index
    @kwikee_api_job_files = KwikeeApiJobFile.all
  end

  # GET /kwikee_api_job_files/1
  # GET /kwikee_api_job_files/1.json
  def show
  end

  # GET /kwikee_api_job_files/new
  def new
    @kwikee_api_job_file = KwikeeApiJobFile.new
  end

  # GET /kwikee_api_job_files/1/edit
  def edit
  end

  # POST /kwikee_api_job_files
  # POST /kwikee_api_job_files.json
  def create
    @kwikee_api_job_file = KwikeeApiJobFile.new(kwikee_api_job_file_params)

    respond_to do |format|
      if @kwikee_api_job_file.save
        format.html { redirect_to @kwikee_api_job_file, notice: 'Kwikee api job file was successfully created.' }
        format.json { render action: 'show', status: :created, location: @kwikee_api_job_file }
      else
        format.html { render action: 'new' }
        format.json { render json: @kwikee_api_job_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kwikee_api_job_files/1
  # PATCH/PUT /kwikee_api_job_files/1.json
  def update
    respond_to do |format|
      if @kwikee_api_job_file.update(kwikee_api_job_file_params)
        format.html { redirect_to @kwikee_api_job_file, notice: 'Kwikee api job file was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @kwikee_api_job_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kwikee_api_job_files/1
  # DELETE /kwikee_api_job_files/1.json
  def destroy
    @kwikee_api_job_file.destroy
    respond_to do |format|
      format.html { redirect_to kwikee_api_job_files_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kwikee_api_job_file
      @kwikee_api_job_file = KwikeeApiJobFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def kwikee_api_job_file_params
      params.require(:kwikee_api_job_file).permit(:kwikee_api_job_id, :status, :file_name)
    end
end
