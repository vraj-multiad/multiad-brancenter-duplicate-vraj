class DynamicFormsController < ApplicationController
  before_action :set_dynamic_form, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?, except: [:display_form, :submit_form, :display_submissions, :display_submitted_form, :get_attachment_form]

  def get_attachment_form
    @dynamic_form = DynamicForm.find_by(token: params[:token])
    @dynamic_form_input = DynamicFormInput.find(params[:dynamic_form_input_id])
    # verify dynamic_form
    return render nothing: true unless @dynamic_form.present? && @dynamic_form_input.present? && @dynamic_form_input.dynamic_form_input_group.dynamic_form.id == @dynamic_form.id
    @user = current_user
    render partial: 'users/attachment_upload'
  end

  def display_form
    @dynamic_form = DynamicForm.find_by(token: params[:token])
    fail unless @dynamic_form
    @user = current_user
    @dynamic_form_submission = DynamicFormSubmission.new
    # render partial: '_display_form'
    render '_display_form'
  end

  def submit_form
    @dynamic_form = DynamicForm.find_by(token: params[:dynamic_form][:token])
    fail unless @dynamic_form
    @dynamic_form_submission = @dynamic_form.dynamic_form_submissions.new(user_id: current_user.id)

    respond_to do |format|
      dynamic_form_submission_properties = params[:dynamic_form][:properties]
      # store original form inputs for historical purposes
      form_mapping = []
      @dynamic_form.dynamic_form_input_groups.each do |dfig|
        dfig.dynamic_form_inputs.each do |dfi|
          form_mapping << { dfi.name => dfi.title }
        end
      end
      dynamic_form_submission_properties[:form_mapping] = form_mapping
      if @dynamic_form_submission.update_attributes(properties: dynamic_form_submission_properties)
        @dynamic_form_submission.submit_email
        format.html { redirect_to display_submitted_form_path(@dynamic_form_submission.token), notice: 'Form submitted.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dynamic_form.errors, status: :unprocessable_entity }
      end
    end
  end

  def display_submissions
    @dynamic_form ||= DynamicForm.find_by(token: params[:token])
    # render partial: '_form_submissions'
    render '_form_submissions'
  end

  def display_submitted_form
    @dynamic_form_submission = DynamicFormSubmission.find_by(token: params[:token])
    @dynamic_form = @dynamic_form_submission.dynamic_form
    # render partial: '_submitted_form'
    render '_submitted_form'
  end

  def delete_submitted_form
    @dynamic_form_submission = DynamicFormSubmission.find_by(token: params[:token])
    @dynamic_form = @dynamic_form_submission.dynamic_form
    @dynamic_form_submission.destroy
    redirect_to form_submissions_path(@dynamic_form.token)
  end

  # GET /dynamic_forms
  # GET /dynamic_forms.json
  def index
    @dynamic_forms = DynamicForm.all
  end

  # GET /dynamic_forms/1
  # GET /dynamic_forms/1.json
  def show
  end

  # GET /dynamic_forms/new
  def new
    @dynamic_form = DynamicForm.new
  end

  # GET /dynamic_forms/1/edit
  def edit
  end

  # POST /dynamic_forms
  # POST /dynamic_forms.json
  def create
    @dynamic_form = DynamicForm.new(dynamic_form_params)

    respond_to do |format|
      if @dynamic_form.save
        format.html { redirect_to @dynamic_form, notice: 'Dynamic form was successfully created.' }
        format.json { render action: 'show', status: :created, location: @dynamic_form }
      else
        format.html { render action: 'new' }
        format.json { render json: @dynamic_form.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dynamic_forms/1
  # PATCH/PUT /dynamic_forms/1.json
  def update
    respond_to do |format|
      if @dynamic_form.update_attributes(dynamic_form_params)
        format.html { redirect_to @dynamic_form, notice: 'Dynamic form was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dynamic_form.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dynamic_forms/1
  # DELETE /dynamic_forms/1.json
  def destroy
    @dynamic_form.destroy
    respond_to do |format|
      format.html { redirect_to dynamic_forms_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dynamic_form
      @dynamic_form = DynamicForm.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dynamic_form_params
      params.require(:dynamic_form).permit(:name, :title, :description, :email_text, :response_text, :recipient, :recipient_field, :expired, :published, :language_id)
    end
end
