class MarketingEmailsController < ApplicationController
  before_action :set_marketing_email, only: [:show, :edit, :update, :destroy]
  before_action :superuser?

  # GET /marketing_emails
  # GET /marketing_emails.json
  def index
    @marketing_emails = MarketingEmail.all
  end

  # GET /marketing_emails/1
  # GET /marketing_emails/1.json
  def show
  end

  # GET /marketing_emails/new
  def new
    @marketing_email = MarketingEmail.new
  end

  # GET /marketing_emails/1/edit
  def edit
  end

  # POST /marketing_emails
  # POST /marketing_emails.json
  def create
    @marketing_email = MarketingEmail.new(marketing_email_params)

    respond_to do |format|
      if @marketing_email.save
        format.html { redirect_to @marketing_email, notice: 'Marketing email was successfully created.' }
        format.json { render action: 'show', status: :created, location: @marketing_email }
      else
        format.html { render action: 'new' }
        format.json { render json: @marketing_email.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /marketing_emails/1
  # PATCH/PUT /marketing_emails/1.json
  def update
    respond_to do |format|
      if @marketing_email.update(marketing_email_params)
        format.html { redirect_to @marketing_email, notice: 'Marketing email was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @marketing_email.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /marketing_emails/1
  # DELETE /marketing_emails/1.json
  def destroy
    @marketing_email.destroy
    respond_to do |format|
      format.html { redirect_to marketing_emails_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_marketing_email
      @marketing_email = MarketingEmail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def marketing_email_params
      params.require(:marketing_email).permit(:ac_export_id, :user_id, :ac_creator_template_id, :ac_session_history_id, :location, :status, :error_string, :user_error_string)
    end
end
