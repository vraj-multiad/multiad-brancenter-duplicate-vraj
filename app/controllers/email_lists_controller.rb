class EmailListsController < ApplicationController
  before_action :set_email_list, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?, only: [:upload_form, :create, :create_list, :parse_sheet, :delete_list, :set_title]
  before_action :superuser?, except: [:upload_form, :create, :create_list, :parse_sheet, :delete_list, :set_title]

  def delete_list
    email_list = current_user.email_lists.where(token: params[:token]).take if params[:token]
    if email_list.present?
      email_list.sendgrid_delete_list
      email_list.destroy
    end
    render partial: 'user_email_lists', locals: { email_lists: current_user.email_lists }
  end

  def parse_sheet_results
    # allow chaining from create as well as cyclical processing from form passing token
    @email_list ||= EmailList.where(token: params[:token]).take
    @recipient_list = @email_list.recipient_list

    # variable data email to come later
    render 'parse_sheet', layout: 'includes_only'
  end

  # GET /email_lists
  # GET /email_lists.json
  def index
    @email_lists = EmailList.all
  end

  # GET /email_lists/1
  # GET /email_lists/1.json
  def show
  end

  # GET /email_lists/new
  def new
    @email_list = EmailList.new
  end

  # GET /email_lists/1/edit
  def edit
  end

  def create_list
    @email_list = EmailList.new(email_s3_create_params)
    @email_list.name = SecureRandom.urlsafe_base64(nil, false)
    @email_list.title = Time.now.strftime('%m/%d/%Y : %l:%M %p')
    if @email_list.save
      parse_sheet_results
    else
      redirect_to profile_url
    end
  end

  def set_title
    if params[:token].present? && params[:title].present?
      @email_list = EmailList.where(token: params[:token]).take
      # we do not change the name of the list
      @email_list.user_id = current_user.id
      @email_list.title = params[:title] + ' - ' + @email_list.created_at.strftime('%m/%d/%Y : %l:%M %p') if @email_list.title.present?
      if @email_list.save
        @user = current_user
        # provision sendgrid list
        @email_list.sendgrid_create_list
      else
        # return to same page with validation errors
        return parse_sheet_results
      end
    end
    redirect_to email_list_upload_form_url
  end

  def upload_form
    @email_list = EmailList.new.sheet
    @email_list.use_action_status = false
    @email_list.success_action_redirect = url_for controller: 'email_lists', action: 'create_list'
    render 'upload_form', layout: 'includes_only'
  end

  # PATCH/PUT /email_lists/1
  # PATCH/PUT /email_lists/1.json
  def update
    respond_to do |format|
      if @email_list.update(email_list_params)
        format.html { redirect_to @email_list, notice: 'Email list was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @email_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /email_lists/1
  # DELETE /email_lists/1.json
  def destroy
    @email_list.destroy
    respond_to do |format|
      format.html { redirect_to email_lists_url }
      format.json { head :no_content }
    end
  end

  private
    def email_s3_create_params
      params.permit(:key)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_email_list
      @email_list = EmailList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def email_list_params
      params.require(:email_list).permit(:user_id, :name, :title, :sheet, :key)
    end
end
