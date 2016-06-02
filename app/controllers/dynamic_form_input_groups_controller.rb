class DynamicFormInputGroupsController < ApplicationController
  before_action :set_dynamic_form_input_group, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?

  def copy
    dynamic_form_input_group = DynamicFormInputGroup.find(params[:id]).deep_copy
    redirect_to edit_dynamic_form_input_group_path(dynamic_form_input_group)
  end

  # GET /dynamic_form_input_groups
  # GET /dynamic_form_input_groups.json
  def index
    @dynamic_form_input_groups = DynamicFormInputGroup.all
  end

  # GET /dynamic_form_input_groups/1
  # GET /dynamic_form_input_groups/1.json
  def show
  end

  # GET /dynamic_form_input_groups/new
  def new
    @html_classes = html_classes
    @dynamic_form_input_group = DynamicFormInputGroup.new
    @available_dynamic_form_dl_images = DlImage.joins(:keywords).where(keywords: { term: 'dynamic_form_input', keyword_type: 'search' }).pluck(:name, :id)
  end

  # GET /dynamic_form_input_groups/1/edit
  def edit
    @html_classes = html_classes
    @available_dynamic_form_dl_images = DlImage.joins(:keywords).where(keywords: { term: 'dynamic_form_input', keyword_type: 'search' }).pluck(:name, :id)
  end

  # POST /dynamic_form_input_groups
  # POST /dynamic_form_input_groups.json
  def create
    @dynamic_form_input_group = DynamicFormInputGroup.new(dynamic_form_input_group_params)

    respond_to do |format|
      if @dynamic_form_input_group.save
        format.html { redirect_to @dynamic_form_input_group, notice: 'Dynamic form input group was successfully created.' }
        format.json { render action: 'show', status: :created, location: @dynamic_form_input_group }
      else
        format.html { render action: 'new' }
        format.json { render json: @dynamic_form_input_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dynamic_form_input_groups/1
  # PATCH/PUT /dynamic_form_input_groups/1.json
  def update
    respond_to do |format|
      if @dynamic_form_input_group.update(dynamic_form_input_group_params)
        format.html { redirect_to @dynamic_form_input_group, notice: 'Dynamic form input group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dynamic_form_input_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dynamic_form_input_groups/1
  # DELETE /dynamic_form_input_groups/1.json
  def destroy
    @dynamic_form_input_group.destroy
    respond_to do |format|
      format.html { redirect_to dynamic_form_input_groups_url }
      format.json { head :no_content }
    end
  end

  def html_classes
    [['full', 'col-lg-12'], ['half', 'col-lg-6 col-md-6 col-sm-6 col-xs-12'], ['third', 'col-lg-4 col-md-4 col-sm-6 col-xs-12'], ['fourth', 'col-lg-3 col-md-6 col-sm-6 col-xs-12']]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dynamic_form_input_group
      @dynamic_form_input_group = DynamicFormInputGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dynamic_form_input_group_params
      params.require(:dynamic_form_input_group).permit(:dynamic_form_id, :name, :title, :description, :input_group_type, :dynamic_form_id, :html_class, dynamic_form_inputs_attributes: [:name, :title, :description, :input_type, :input_choices, :html_class, :required, :_destroy, :id, :dl_image_id, :min_date, :max_date])
    end
end
