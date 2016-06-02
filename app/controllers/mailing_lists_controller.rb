class MailingListsController < ApplicationController
  before_action :set_mailing_list, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?, only: [:upload_form, :create, :create_list, :parse_sheet, :delete_list, :set_title]
  before_action :superuser?, except: [:upload_form, :create, :create_list, :parse_sheet, :delete_list, :set_title]


  def delete_list
    mailing_list = current_user.mailing_lists.where(token: params[:token]).take if params[:token]
    if mailing_list.present?
      mailing_list.destroy
    end
    render partial: 'user_mailing_lists', locals: { mailing_lists: current_user.mailing_lists }
  end

  def parse_sheet_results
    # allow chaining from create as well as cyclical processing from form passing token
    @mailing_list ||= MailingList.where(token: params[:token]).take
    @recipient_list = @mailing_list.recipient_list

    # variable data email to come later
    render 'parse_sheet', layout: 'includes_only'
  end

  # GET /mailing_lists
  # GET /mailing_lists.json
  def index
    @mailing_lists = MailingList.all
  end

  # GET /mailing_lists/1
  # GET /mailing_lists/1.json
  def show
  end

  # GET /mailing_lists/new
  def new
    @mailing_list = MailingList.new
  end

  # GET /mailing_lists/1/edit
  def edit
  end

  def create_list
    @mailing_list = MailingList.new(mailing_list_s3_create_params)
    @mailing_list.name = SecureRandom.urlsafe_base64(nil, false)
    @mailing_list.title = Time.now.strftime('%m/%d/%Y : %l:%M %p')
    if @mailing_list.save
      parse_sheet_results
    else
      redirect_to profile_url
    end
  end

  def set_title
    if params[:token].present? && params[:title].present?
      @mailing_list = MailingList.where(token: params[:token]).take
      # we do not change the name of the list
      @mailing_list.user_id = current_user.id
      @mailing_list.quantity = params[:quantity]
      @mailing_list.title = params[:title] + ' - ' + @mailing_list.created_at.strftime('%m/%d/%Y : %l:%M %p') if @mailing_list.title.present?
      if @mailing_list.save
        @user = current_user
      else
        # return to same page with validation errors
        return parse_sheet_results
      end
    end
    redirect_to mailing_list_upload_form_url
  end

  def upload_form
    @mailing_list = MailingList.new.sheet
    @mailing_list.use_action_status = false
    @mailing_list.success_action_redirect = url_for controller: 'mailing_lists', action: 'create_list'
    render 'upload_form', layout: 'includes_only'
  end


  # PATCH/PUT /mailing_lists/1
  # PATCH/PUT /mailing_lists/1.json
  def update
    respond_to do |format|
      if @mailing_list.update(mailing_list_params)
        format.html { redirect_to @mailing_list, notice: 'Mailing list was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @mailing_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mailing_lists/1
  # DELETE /mailing_lists/1.json
  def destroy
    @mailing_list.destroy
    respond_to do |format|
      format.html { redirect_to mailing_lists_url }
      format.json { head :no_content }
    end
  end

  private
    def mailing_list_s3_create_params
      params.permit(:key)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_mailing_list
      @mailing_list = MailingList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mailing_list_params
      params.require(:mailing_list).permit(:user_id, :name, :title, :sheet, :status, :list_type, :token)
    end
end
