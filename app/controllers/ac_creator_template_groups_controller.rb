class AcCreatorTemplateGroupsController < ApplicationController
  before_action :set_ac_creator_template_group, only: [:show, :edit, :update, :destroy]
  before_action :superuser?

  # GET /ac_creator_template_groups
  # GET /ac_creator_template_groups.json
  def index
    @ac_creator_template_groups = AcCreatorTemplateGroup.all
  end

  # GET /ac_creator_template_groups/1
  # GET /ac_creator_template_groups/1.json
  def show
  end

  # GET /ac_creator_template_groups/new
  def new
    @ac_creator_template_group = AcCreatorTemplateGroup.new
    @sub_templates = AcCreatorTemplate.sub_templates.available.order(:ac_creator_template_type, :name, :status)
  end

  # GET /ac_creator_template_groups/1/edit
  def edit
    @sub_templates = AcCreatorTemplate.sub_templates.available.order(:ac_creator_template_type, :name, :status)
  end

  # POST /ac_creator_template_groups
  # POST /ac_creator_template_groups.json
  def create
    @ac_creator_template_group = AcCreatorTemplateGroup.new(ac_creator_template_group_params)

    respond_to do |format|
      if @ac_creator_template_group.save
        format.html { redirect_to @ac_creator_template_group, notice: 'Ac creator template group was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ac_creator_template_group }
      else
        format.html { render action: 'new' }
        format.json { render json: @ac_creator_template_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ac_creator_template_groups/1
  # PATCH/PUT /ac_creator_template_groups/1.json
  def update
    respond_to do |format|

      update_params = ac_creator_template_group_params
      update_params[:ac_creator_template_ids] = AcCreatorTemplate.where(id: update_params[:ac_creator_template_ids]).pluck(:id)

      if @ac_creator_template_group.update(update_params)
        format.html { redirect_to @ac_creator_template_group, notice: 'Ac creator template group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ac_creator_template_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ac_creator_template_groups/1
  # DELETE /ac_creator_template_groups/1.json
  def destroy
    @ac_creator_template_group.destroy
    respond_to do |format|
      format.html { redirect_to ac_creator_template_groups_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ac_creator_template_group
      @ac_creator_template_group = AcCreatorTemplateGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ac_creator_template_group_params
      params.require(:ac_creator_template_group).permit(:name, :title, :token, :spec, ac_creator_template_ids: [])
    end
end
