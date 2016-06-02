class KwikeeCustomDataController < ApplicationController
  before_action :set_kwikee_custom_datum, only: [:show, :edit, :update, :destroy]

  # GET /kwikee_custom_data
  # GET /kwikee_custom_data.json
  def index
    @kwikee_custom_data = KwikeeCustomDatum.all
  end

  # GET /kwikee_custom_data/1
  # GET /kwikee_custom_data/1.json
  def show
  end

  # GET /kwikee_custom_data/new
  def new
    @kwikee_custom_datum = KwikeeCustomDatum.new
  end

  # GET /kwikee_custom_data/1/edit
  def edit
  end

  # POST /kwikee_custom_data
  # POST /kwikee_custom_data.json
  def create
    @kwikee_custom_datum = KwikeeCustomDatum.new(kwikee_custom_datum_params)

    respond_to do |format|
      if @kwikee_custom_datum.save
        format.html { redirect_to @kwikee_custom_datum, notice: 'Kwikee custom datum was successfully created.' }
        format.json { render action: 'show', status: :created, location: @kwikee_custom_datum }
      else
        format.html { render action: 'new' }
        format.json { render json: @kwikee_custom_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kwikee_custom_data/1
  # PATCH/PUT /kwikee_custom_data/1.json
  def update
    respond_to do |format|
      if @kwikee_custom_datum.update(kwikee_custom_datum_params)
        format.html { redirect_to @kwikee_custom_datum, notice: 'Kwikee custom datum was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @kwikee_custom_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kwikee_custom_data/1
  # DELETE /kwikee_custom_data/1.json
  def destroy
    @kwikee_custom_datum.destroy
    respond_to do |format|
      format.html { redirect_to kwikee_custom_data_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kwikee_custom_datum
      @kwikee_custom_datum = KwikeeCustomDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def kwikee_custom_datum_params
      params.require(:kwikee_custom_datum).permit(:kwikee_product_id, :kwikee_profile_id, :name)
    end
end
