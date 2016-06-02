class ImageUploadCallbackController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

#   http_basic_authenticate_with :realm => 'Asset Callback', :name => ENV['ASSET_CALLBACK_AUTHEN_NAME'], :password => ENV['ASSET_CALLBACK_AUTHEN_PASSWORD']

  def dl_image_zencoder
    logger.debug 'dl_image zencoder callback'
    logger.debug params.to_yaml

    job_id = params['job']['id']
    video = DlImage.find_by! job_id: job_id.to_s

    # weak security measure
    if video.created_at.today?
      # video.finish_video_processing params

      state = params['job']['state']

      if state == 'finished'
        video.status = 'staged'
      elsif state =='failed'
        video.status = 'processing failed'
      else
        logger.error "Failed to determine zencoder job result for state #{state} and asset #{video.id}"
      end

      video.save!
      #send setup xml to MASI
      # xml = admin_dl_image_xml(video)
      # dispatch_dl_image_request(xml)

      video.add_default_keywords
    end

    head :ok
  end

  def user_uploaded_image_blitline
    logger.debug 'user_uploaded_image blitline callback'
    logger.debug params.inspect

    UploadWorker.perform_async('update_blitline_status', 'user_uploaded_image', params[:results])

    head :ok
  end

  def dl_image_blitline
    logger.debug 'dl_image blitline callback'
    logger.debug params.to_yaml

    UploadWorker.perform_async('update_blitline_status', 'dl_image', params[:results])

    head :ok
  end

  def user_uploaded_image_zencoder
    logger.debug 'user_uploaded_image zencoder callback'
    logger.debug params.to_yaml

    job_id = params['job']['id']
    video = UserUploadedImage.find_by! job_id: job_id.to_s

    # weak security measure
    if video.created_at.today?
      # video.finish_video_processing params

      state = params['job']['state']

      if state == 'finished'
        video.status = 'processed'
      elsif state =='failed'
        video.status = 'processing failed'
      else
        logger.error "Failed to determine zencoder job result for state #{state} and asset #{video.id}"
      end

      video.save!


    end

    head :ok
  end
end
