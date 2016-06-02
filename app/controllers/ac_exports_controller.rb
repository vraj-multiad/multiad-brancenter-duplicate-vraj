class AcExportsController < ApplicationController
  before_action :set_ac_export, only: [:show, :edit, :update, :destroy]
  before_action :admin?, only: [:admin]
  before_action :superuser?, except: [:admin]

  def admin
    if params[:token].present? && params[:operation].present?
      oq = OperationQueue.find_by(token: params[:token])
      if oq.present? && oq.status == 'ready' && %w(approve deny).include?(params[:operation])
        oq.operable.send(params[:operation], params[:comments])
        oq.operation_type = params[:operation]
        message = current_user.username
        message += ': ' + params[:comments] if params[:comments].present?
        oq.error_message = message
        oq.complete
      end
    else
      logger.debug 'token not found'
    end
    redirect_to admin_approve_documents_path
  end

  # GET /ac_exports
  # GET /ac_exports.json
  def index
    @ac_exports = AcExport.all.order(ac_session_history_id: :asc, id: :asc)
  end

  # GET /ac_exports/1
  # GET /ac_exports/1.json
  def show
  end

  # GET /ac_exports/new
  def new
    @ac_export = AcExport.new
  end

  # GET /ac_exports/1/edit
  def edit
  end

  # POST /ac_exports
  # POST /ac_exports.json
  def create
    @ac_export = AcExport.new(ac_export_params)

    respond_to do |format|
      if @ac_export.save
        format.html { redirect_to @ac_export, notice: 'Ac export was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ac_export }
      else
        format.html { render action: 'new' }
        format.json { render json: @ac_export.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ac_exports/1
  # PATCH/PUT /ac_exports/1.json
  def update
    respond_to do |format|
      if @ac_export.update(ac_export_params)
        format.html { redirect_to @ac_export, notice: 'Ac export was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ac_export.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ac_exports/1
  # DELETE /ac_exports/1.json
  def destroy
    @ac_export.destroy
    respond_to do |format|
      format.html { redirect_to ac_exports_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ac_export
      @ac_export = AcExport.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ac_export_params
      params.require(:ac_export).permit(:ac_session_history_id, :email_address, :format, :location)
    end
end
