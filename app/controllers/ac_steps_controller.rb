class AcStepsController < ApplicationController
  before_action :set_ac_step, only: [:show, :edit, :update, :destroy]
  before_action :superuser?

  # GET /ac_steps
  # GET /ac_steps.json
  def index
    ac_base_id = params[:ac_base_id]
    @ac_steps = nil
    if ac_base_id
      @ac_steps = AcStep.where(ac_base_id: ac_base_id).order(step_number: :asc)
    else
      @ac_steps = AcStep.all
    end
    @ac_steps
  end

  # GET /ac_steps/1
  # GET /ac_steps/1.json
  def show
  end

  # GET /ac_steps/new
  def new
    @ac_step = AcStep.new
  end

  # GET /ac_steps/1/edit
  def edit
  end

  # POST /ac_steps
  # POST /ac_steps.json
  def create
    @ac_step = AcStep.new(ac_step_params)

    respond_to do |format|
      if @ac_step.save
        @ac_step.update_responds_to_attributes params['responds_to_attribute_list'] if params['responds_to_attribute_list'].present?
        @ac_step.update_set_attributes params['set_attribute_list'] if params['set_attribute_list'].present?
        format.html { redirect_to @ac_step, notice: 'Ac step was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ac_step }
      else
        format.html { render action: 'new' }
        format.json { render json: @ac_step.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ac_steps/1
  # PATCH/PUT /ac_steps/1.json
  def update
    respond_to do |format|
      if @ac_step.update(ac_step_params)
        @ac_step.update_responds_to_attributes params['responds_to_attribute_list'] if params['responds_to_attribute_list'].present?
        @ac_step.update_set_attributes params['set_attribute_list'] if params['set_attribute_list'].present?
        format.html { redirect_to @ac_step, notice: 'Ac step was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ac_step.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ac_steps/1
  # DELETE /ac_steps/1.json
  def destroy
    @ac_step.destroy
    respond_to do |format|
      format.html { redirect_to ac_steps_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ac_step
      @ac_step = AcStep.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ac_step_params
      params.require(:ac_step).permit(:name, :title, :actions, :form, :ac_base_id, :step_number)
    end
end
