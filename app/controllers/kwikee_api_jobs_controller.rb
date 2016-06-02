class KwikeeApiJobsController < ApplicationController
  before_action :set_kwikee_api_job, only: [:show, :edit, :update, :destroy]
  before_action :superuser?

  def init
    inits = KwikeeApiJob.where(job_type: 'init')
    if inits.count > 0
      @kwikee_api_job = inits.take
      redirect_to @kwikee_api_job, notice: 'Already initialized, please remove old init before re-initilization'
    else
      init_job_params = {
        job_type: 'init',
        replication_date: Time.now.at_beginning_of_day - 1.day,
        status: 'created'
      }
      @kwikee_api_job = KwikeeApiJob.new(init_job_params)
      @kwikee_api_job.save!
      logger.debug @kwikee_api_job
      KwikeeWorker.perform_in(2.seconds, 'process_job', @kwikee_api_job.id)
      redirect_to @kwikee_api_job, notice: 'Kwikee api job was successfully created.'
    end
  end

  # GET /kwikee_api_jobs
  # GET /kwikee_api_jobs.json
  def index
    @kwikee_api_jobs = KwikeeApiJob.all
  end

  # GET /kwikee_api_jobs/1
  # GET /kwikee_api_jobs/1.json
  def show
  end

  # GET /kwikee_api_jobs/new
  def new
    @kwikee_api_job = KwikeeApiJob.new
  end

  # GET /kwikee_api_jobs/1/edit
  def edit
  end

  # POST /kwikee_api_jobs
  # POST /kwikee_api_jobs.json
  def create
    @kwikee_api_job = KwikeeApiJob.new(kwikee_api_job_params)

    respond_to do |format|
      if @kwikee_api_job.save
        format.html { redirect_to @kwikee_api_job, notice: 'Kwikee api job was successfully created.' }
        format.json { render action: 'show', status: :created, location: @kwikee_api_job }
      else
        format.html { render action: 'new' }
        format.json { render json: @kwikee_api_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kwikee_api_jobs/1
  # PATCH/PUT /kwikee_api_jobs/1.json
  def update
    respond_to do |format|
      if @kwikee_api_job.update(kwikee_api_job_params)
        format.html { redirect_to @kwikee_api_job, notice: 'Kwikee api job was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @kwikee_api_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kwikee_api_jobs/1
  # DELETE /kwikee_api_jobs/1.json
  def destroy
    @kwikee_api_job.destroy
    respond_to do |format|
      format.html { redirect_to kwikee_api_jobs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kwikee_api_job
      @kwikee_api_job = KwikeeApiJob.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def kwikee_api_job_params
      params.require(:kwikee_api_job).permit(:job_type, :replication_date, :status, :transaction_id, :response_code, :response_description)
    end
end
