class KwikeeCustomDataAttributesController < ApplicationController
  before_action :set_kwikee_custom_data_attribute, only: [:show, :edit, :update, :destroy]

  # GET /kwikee_custom_data_attributes
  # GET /kwikee_custom_data_attributes.json
  def index
    @kwikee_custom_data_attributes = KwikeeCustomDataAttribute.all
  end

  # GET /kwikee_custom_data_attributes/1
  # GET /kwikee_custom_data_attributes/1.json
  def show
  end

  # GET /kwikee_custom_data_attributes/new
  def new
    @kwikee_custom_data_attribute = KwikeeCustomDataAttribute.new
  end

  # GET /kwikee_custom_data_attributes/1/edit
  def edit
  end

  # POST /kwikee_custom_data_attributes
  # POST /kwikee_custom_data_attributes.json
  def create
    @kwikee_custom_data_attribute = KwikeeCustomDataAttribute.new(kwikee_custom_data_attribute_params)

    respond_to do |format|
      if @kwikee_custom_data_attribute.save
        format.html { redirect_to @kwikee_custom_data_attribute, notice: 'Kwikee custom data attribute was successfully created.' }
        format.json { render action: 'show', status: :created, location: @kwikee_custom_data_attribute }
      else
        format.html { render action: 'new' }
        format.json { render json: @kwikee_custom_data_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kwikee_custom_data_attributes/1
  # PATCH/PUT /kwikee_custom_data_attributes/1.json
  def update
    respond_to do |format|
      if @kwikee_custom_data_attribute.update(kwikee_custom_data_attribute_params)
        format.html { redirect_to @kwikee_custom_data_attribute, notice: 'Kwikee custom data attribute was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @kwikee_custom_data_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kwikee_custom_data_attributes/1
  # DELETE /kwikee_custom_data_attributes/1.json
  def destroy
    @kwikee_custom_data_attribute.destroy
    respond_to do |format|
      format.html { redirect_to kwikee_custom_data_attributes_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kwikee_custom_data_attribute
      @kwikee_custom_data_attribute = KwikeeCustomDataAttribute.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def kwikee_custom_data_attribute_params
      params.require(:kwikee_custom_data_attribute).permit(:kwikee_custom_datum_id, :name, :value)
    end
end
