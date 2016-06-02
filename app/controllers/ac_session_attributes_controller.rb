class AcSessionAttributesController < ApplicationController
  before_action :set_ac_session_attribute, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?

  # GET /ac_session_attributes
  # GET /ac_session_attributes.json
  def index
    @ac_session_attributes = AcSessionAttribute.all
  end

  # GET /ac_session_attributes/1
  # GET /ac_session_attributes/1.json
  def show
  end

  # GET /ac_session_attributes/new
  def new
    @ac_session_attribute = AcSessionAttribute.new
  end

  # GET /ac_session_attributes/1/edit
  def edit
  end

  # POST /ac_session_attributes
  # POST /ac_session_attributes.json
  def create
    @ac_session_attribute = AcSessionAttribute.new(ac_session_attribute_params)

    respond_to do |format|
      if @ac_session_attribute.save
        format.html { redirect_to @ac_session_attribute, notice: 'Ac session attribute was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ac_session_attribute }
      else
        format.html { render action: 'new' }
        format.json { render json: @ac_session_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ac_session_attributes/1
  # PATCH/PUT /ac_session_attributes/1.json
  def update
    respond_to do |format|
      if @ac_session_attribute.update(ac_session_attribute_params)
        format.html { redirect_to @ac_session_attribute, notice: 'Ac session attribute was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ac_session_attribute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ac_session_attributes/1
  # DELETE /ac_session_attributes/1.json
  def destroy
    @ac_session_attribute.destroy
    respond_to do |format|
      format.html { redirect_to ac_session_attributes_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ac_session_attribute
      @ac_session_attribute = AcSessionAttribute.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ac_session_attribute_params
      params.require(:ac_session_attribute).permit(:ac_session_history_id, :name, :value, :adcreator_step_id, :attribute_type)
    end
end
