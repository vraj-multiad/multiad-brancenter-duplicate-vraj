class SetAttributesController < ApplicationController
  before_action :set_set_attribute, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?

  # GET /set_attributes
  # GET /set_attributes.json
  def index
    @set_attributes = SetAttribute.all
  end

  # GET /set_attributes/1
  # GET /set_attributes/1.json
  def show
  end

  # GET /set_attributes/new
  def new
    @set_attribute = SetAttribute.new
  end

  # GET /set_attributes/1/edit
  def edit
  end

  # POST /set_attributes
  # POST /set_attributes.json
  def create
    @set_attribute = SetAttribute.new(set_attribute_params)

    respond_to do |format|
      if @set_attribute.save
        format.html { redirect_to @set_attribute, notice: 'Set attribute was successfully created.' }
        format.json { render action: 'show', status: :created, location: @set_attribute }
      else
        format.html { render action: 'new' }
        format.json { render json: @set_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /set_attributes/1
  # PATCH/PUT /set_attributes/1.json
  def update
    respond_to do |format|
      if @set_attribute.update(set_attribute_params)
        format.html { redirect_to @set_attribute, notice: 'Set attribute was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @set_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /set_attributes/1
  # DELETE /set_attributes/1.json
  def destroy
    @set_attribute.destroy
    respond_to do |format|
      format.html { redirect_to set_attributes_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_set_attribute
      @set_attribute = SetAttribute.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def set_attribute_params
      params.require(:set_attribute).permit(:setable_id, :setable_type, :name, :value)
    end
end
