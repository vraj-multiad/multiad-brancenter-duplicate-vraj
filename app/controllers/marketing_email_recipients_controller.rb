class MarketingEmailRecipientsController < ApplicationController
  before_action :set_marketing_email_recipient, only: [:show, :edit, :update, :destroy]
  before_action :superuser?

  # GET /marketing_email_recipients
  # GET /marketing_email_recipients.json
  def index
    @marketing_email_recipients = MarketingEmailRecipient.all
  end

  # GET /marketing_email_recipients/1
  # GET /marketing_email_recipients/1.json
  def show
  end

  # GET /marketing_email_recipients/new
  def new
    @marketing_email_recipient = MarketingEmailRecipient.new
  end

  # GET /marketing_email_recipients/1/edit
  def edit
  end

  # POST /marketing_email_recipients
  # POST /marketing_email_recipients.json
  def create
    @marketing_email_recipient = MarketingEmailRecipient.new(marketing_email_recipient_params)

    respond_to do |format|
      if @marketing_email_recipient.save
        format.html { redirect_to @marketing_email_recipient, notice: 'Marketing email recipient was successfully created.' }
        format.json { render action: 'show', status: :created, location: @marketing_email_recipient }
      else
        format.html { render action: 'new' }
        format.json { render json: @marketing_email_recipient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /marketing_email_recipients/1
  # PATCH/PUT /marketing_email_recipients/1.json
  def update
    respond_to do |format|
      if @marketing_email_recipient.update(marketing_email_recipient_params)
        format.html { redirect_to @marketing_email_recipient, notice: 'Marketing email recipient was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @marketing_email_recipient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /marketing_email_recipients/1
  # DELETE /marketing_email_recipients/1.json
  def destroy
    @marketing_email_recipient.destroy
    respond_to do |format|
      format.html { redirect_to marketing_email_recipients_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_marketing_email_recipient
      @marketing_email_recipient = MarketingEmailRecipient.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def marketing_email_recipient_params
      params.require(:marketing_email_recipient).permit(:marketing_email_id, :email_address)
    end
end
