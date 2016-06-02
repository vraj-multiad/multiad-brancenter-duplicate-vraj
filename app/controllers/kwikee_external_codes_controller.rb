class KwikeeExternalCodesController < ApplicationController
  before_action :set_kwikee_external_code, only: [:show, :edit, :update, :destroy]

  # GET /kwikee_external_codes
  # GET /kwikee_external_codes.json
  def index
    @kwikee_external_codes = KwikeeExternalCode.all
  end

  # GET /kwikee_external_codes/1
  # GET /kwikee_external_codes/1.json
  def show
  end

  # GET /kwikee_external_codes/new
  def new
    @kwikee_external_code = KwikeeExternalCode.new
  end

  # GET /kwikee_external_codes/1/edit
  def edit
  end

  # POST /kwikee_external_codes
  # POST /kwikee_external_codes.json
  def create
    @kwikee_external_code = KwikeeExternalCode.new(kwikee_external_code_params)

    respond_to do |format|
      if @kwikee_external_code.save
        format.html { redirect_to @kwikee_external_code, notice: 'Kwikee external code was successfully created.' }
        format.json { render action: 'show', status: :created, location: @kwikee_external_code }
      else
        format.html { render action: 'new' }
        format.json { render json: @kwikee_external_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kwikee_external_codes/1
  # PATCH/PUT /kwikee_external_codes/1.json
  def update
    respond_to do |format|
      if @kwikee_external_code.update(kwikee_external_code_params)
        format.html { redirect_to @kwikee_external_code, notice: 'Kwikee external code was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @kwikee_external_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kwikee_external_codes/1
  # DELETE /kwikee_external_codes/1.json
  def destroy
    @kwikee_external_code.destroy
    respond_to do |format|
      format.html { redirect_to kwikee_external_codes_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kwikee_external_code
      @kwikee_external_code = KwikeeExternalCode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def kwikee_external_code_params
      params.require(:kwikee_external_code).permit(:kwikee_product_id, :kwikee_profile_id, :name, :value)
    end
end
