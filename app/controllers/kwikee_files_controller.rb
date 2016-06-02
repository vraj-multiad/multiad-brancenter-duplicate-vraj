class KwikeeFilesController < ApplicationController
  before_action :set_kwikee_file, only: [:show, :edit, :update, :destroy]
  before_action :superuser?

  # GET /kwikee_files
  # GET /kwikee_files.json
  def index
    @kwikee_files = KwikeeFile.all
  end

  # GET /kwikee_files/1
  # GET /kwikee_files/1.json
  def show
  end

  # GET /kwikee_files/new
  def new
    @kwikee_file = KwikeeFile.new
  end

  # GET /kwikee_files/1/edit
  def edit
  end

  # POST /kwikee_files
  # POST /kwikee_files.json
  def create
    @kwikee_file = KwikeeFile.new(kwikee_file_params)

    respond_to do |format|
      if @kwikee_file.save
        format.html { redirect_to @kwikee_file, notice: 'Kwikee file was successfully created.' }
        format.json { render action: 'show', status: :created, location: @kwikee_file }
      else
        format.html { render action: 'new' }
        format.json { render json: @kwikee_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kwikee_files/1
  # PATCH/PUT /kwikee_files/1.json
  def update
    respond_to do |format|
      if @kwikee_file.update(kwikee_file_params)
        format.html { redirect_to @kwikee_file, notice: 'Kwikee file was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @kwikee_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kwikee_files/1
  # DELETE /kwikee_files/1.json
  def destroy
    @kwikee_file.destroy
    respond_to do |format|
      format.html { redirect_to kwikee_files_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kwikee_file
      @kwikee_file = KwikeeFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def kwikee_file_params
      params.require(:kwikee_file).permit(:kwikee_product_id, :kwikee_asset_id, :extension, :url)
    end
end
