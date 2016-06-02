class UploadWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5, dead: false

  def perform(method, *params)
    send(method.to_sym, *params)
  end

  def poll_s3_for_blitline_success(klass, id, *params)
    model = klass.classify.constantize.find(id)
    model.poll_s3_for_blitline_success(*params)
  rescue ActiveRecord::RecordNotFound
    logger.warn "failed to find #{klass} with id #{id} for polling s3, assuming it was deleted"
  end

  def start_image_processing(klass, id, *params)
    model = klass.classify.constantize.find(id)
    model.start_image_processing(*params)
  end

  def start_video_processing(klass, id, *params)
    model = klass.classify.constantize.find(id)
    model.start_video_processing(*params)
  end

  def update_blitline_status(klass, *params)
    klass.classify.constantize.update_blitline_status(*params)
  end
end
