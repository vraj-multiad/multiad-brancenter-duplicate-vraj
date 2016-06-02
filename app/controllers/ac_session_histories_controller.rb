class AcSessionHistoriesController < ApplicationController
  before_action :set_ac_session_history, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?, except: [:expire]

  def admin_open_sessions
    @ac_sessions = AcSession.joins(ac_session_histories: :ac_document).where(ac_sessions: { locked: true }, ac_session_histories: { expired: false })
  end

  def admin_expire_session
    ac_session = AcSession.find(params[:id])
    redirect_to admin_open_sessions_path unless ac_session.present?

    system_message = 'admin_expire_session' + "\n"
    system_message += "initiator: #{current_user.username} (#{current_user.id}) #{current_user.email_address} " + "\n"
    system_message += "session_id: #{ac_session.id} " + "\n"

    if ac_session.locked
      ac_session.unlock!
      logger.info "AcSession unlock! #{ac_session.id}"
      system_message += 'AcSession unlock! called' + "\n"
    end

    ac_session.ac_session_histories.each do |ac_session_history|
      next if ac_session_history.expired
      ac_session_history.expire!
      system_message += "dependent ac_session_history: (#{ac_session_history.id}) #{ac_session_history.name} " + "\n"
      logger.info 'AcSessionHistory.expire! ' + ac_session_history.id.to_s
    end
    subject = "ac_session_histories: admin_expire_session #{ac_session.id}"
    UserMailer.system_message_email(subject, system_message).deliver

    redirect_to admin_open_sessions_path
  end

  def admin_repair_session
    # expire bad session
    # unexpire good session
    bad_session = AcSessionHistory.find(params[:bad_session_id])
    good_session = AcSessionHistory.find(params[:good_session_id])
    bad_session.expire!
    good_session.expired = false
    good_session.save
    redirect_to admin_open_sessions_path
  end

  # GET /ac_session_histories
  # GET /ac_session_histories.json
  def index
    @ac_session_histories = AcSessionHistory.order('ac_session_id desc')
  end

  # GET /ac_session_histories/1
  # GET /ac_session_histories/1.json
  def show
  end

  # GET /ac_session_histories/new
  def new
    @ac_session_history = AcSessionHistory.new
  end

  # GET /ac_session_histories/1/edit
  def edit
  end

  # POST /ac_session_histories
  # POST /ac_session_histories.json
  def create
    @ac_session_history = AcSessionHistory.new(ac_session_history_params)

    respond_to do |format|
      if @ac_session_history.save
        format.html { redirect_to @ac_session_history, notice: 'Ac session history was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ac_session_history }
      else
        format.html { render action: 'new' }
        format.json { render json: @ac_session_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ac_session_histories/1
  # PATCH/PUT /ac_session_histories/1.json
  def update
    respond_to do |format|
      if @ac_session_history.update(ac_session_history_params)
        format.html { redirect_to @ac_session_history, notice: 'Ac session history was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ac_session_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ac_session_histories/1
  # DELETE /ac_session_histories/1.json
  def destroy
    @ac_session_history.destroy
    respond_to do |format|
      format.html { redirect_to ac_session_histories_url }
      format.json { head :no_content }
    end
  end

  def expire
    logger.debug 'expire called with id: ' + params[:id].to_s
    ash = AcSessionHistory.find(params[:id])
    if ash.ac_session.user.id == current_user.id
      ash.expired = true
      ash.save!
    end
    respond_to do |format|
      format.html { redirect_to '/' }
      format.json { head :no_content }
    end
  end

  def saved_ads
    @ac_session_histories = AcSessionHistory.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ac_session_histories }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ac_session_history
      @ac_session_history = AcSessionHistory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ac_session_history_params
      params.require(:ac_session_history).permit(:name, :expired, :previous_ac_document_id, :ac_document_id, :ac_session_id, :saved)
    end
end
