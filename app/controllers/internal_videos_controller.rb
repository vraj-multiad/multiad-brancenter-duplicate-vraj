class InternalVideosController < ApplicationController
  before_action :superuser?, except: [:zencoder]

  skip_before_action :verify_authenticity_token, only: [:zencoder]

  def create
    InternalVideo.create!(key: params[:key])
    redirect_to internal_videos_path, notice: 'Video created successfully'
  end

  def edit
    @video = InternalVideo.find params[:id]
  end

  def new
    @video = InternalVideo.new
    @video.video.use_action_status = false
    @video.video.success_action_redirect = create_internal_video_url
  end

  def update
    @video = InternalVideo.find params[:id]
    @video.update!(internal_video_params)
    redirect_to internal_video_path(@video), notice: 'Video updated successfully'
  end

  def zencoder
    job_id = params['job']['id'].to_s
    video = InternalVideo.find_by!(job_id: job_id)

    state = params['job']['state']
    case state
    when 'finished'
      video.status = 'processed'
    when 'failed'
      video.status = 'failed'
    else
      logger.error "unknown state: #{state}"
    end

    video.save!
  end

  private

  def internal_video_params
    params.fetch(:internal_video, {}).permit(:status)
  end
end
