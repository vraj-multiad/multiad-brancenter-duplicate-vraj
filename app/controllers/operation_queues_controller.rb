class OperationQueuesController < ApplicationController
  before_action :set_operation_queue, only: [:show, :edit, :update, :destroy]
  before_action :admin?, only: [:approve_documents]
  before_action :superuser?, except: [:set_operation_queue_status, :approve_documents]

  def approve_documents
    @approve_documents = OperationQueue.approve_documents.ready
    render partial: 'approve_documents'
  end

  def set_operation_queue_status
    if params[:token].present? && params[:status].present?
      queue_item = OperationQueue.where(token: params[:token]).take
      if queue_item.present?
        queue_item.status = params[:status]
        queue_item.error_message = params[:error_message].to_s if params[:error_message].present?
        queue_item.save
      end
    end
    render nothing: true, :status => 200, :content_type => 'text/html'
  end

  # GET /operation_queues
  # GET /operation_queues.json
  def index
    @operation_queues = OperationQueue.all
  end

  # GET /operation_queues/1
  # GET /operation_queues/1.json
  def show
  end

  # GET /operation_queues/new
  def new
    @operation_queue = OperationQueue.new
  end

  # GET /operation_queues/1/edit
  def edit
  end

  # POST /operation_queues
  # POST /operation_queues.json
  def create
    @operation_queue = OperationQueue.new(operation_queue_params)

    respond_to do |format|
      if @operation_queue.save
        format.html { redirect_to @operation_queue, notice: 'Operation queue was successfully created.' }
        format.json { render action: 'show', status: :created, location: @operation_queue }
      else
        format.html { render action: 'new' }
        format.json { render json: @operation_queue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /operation_queues/1
  # PATCH/PUT /operation_queues/1.json
  def update
    respond_to do |format|
      if @operation_queue.update(operation_queue_params)
        format.html { redirect_to @operation_queue, notice: 'Operation queue was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @operation_queue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /operation_queues/1
  # DELETE /operation_queues/1.json
  def destroy
    @operation_queue.destroy
    respond_to do |format|
      format.html { redirect_to operation_queues_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_operation_queue
      @operation_queue = OperationQueue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def operation_queue_params
      params.require(:operation_queue).permit(:operable_type, :operable_id, :queue_type, :operation_type, :operation, :status, :error_message, :path, :alt_path, :scheduled_at, :completed_at)
    end
end
