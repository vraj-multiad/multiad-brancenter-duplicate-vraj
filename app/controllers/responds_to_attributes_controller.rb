class RespondsToAttributesController < ApplicationController
  before_action :set_responds_to_attribute, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?

  # GET /responds_to_attributes
  # GET /responds_to_attributes.json
  def index
    @responds_to_attributes = RespondsToAttribute.all
  end

  # GET /responds_to_attributes/1
  # GET /responds_to_attributes/1.json
  def show
  end

  # GET /responds_to_attributes/new
  def new
    @responds_to_attribute = RespondsToAttribute.new
  end

  # GET /responds_to_attributes/1/edit
  def edit
  end

  # POST /responds_to_attributes
  # POST /responds_to_attributes.json
  def create
    @responds_to_attribute = RespondsToAttribute.new(responds_to_attribute_params)

    respond_to do |format|
      if @responds_to_attribute.save
        format.html { redirect_to @responds_to_attribute, notice: 'Responds to attribute was successfully created.' }
        format.json { render action: 'show', status: :created, location: @responds_to_attribute }
      else
        format.html { render action: 'new' }
        format.json { render json: @responds_to_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /responds_to_attributes/1
  # PATCH/PUT /responds_to_attributes/1.json
  def update
    respond_to do |format|
      if @responds_to_attribute.update(responds_to_attribute_params)
        format.html { redirect_to @responds_to_attribute, notice: 'Responds to attribute was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @responds_to_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /responds_to_attributes/1
  # DELETE /responds_to_attributes/1.json
  def destroy
    @responds_to_attribute.destroy
    respond_to do |format|
      format.html { redirect_to responds_to_attributes_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_responds_to_attribute
      @responds_to_attribute = RespondsToAttribute.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def responds_to_attribute_params
      params.require(:responds_to_attribute).permit(:respondable_id, :respondable_type, :name, :value)
    end
end
