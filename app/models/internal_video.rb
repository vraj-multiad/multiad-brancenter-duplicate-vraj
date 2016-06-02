# == Schema Information
#
# Table name: internal_videos
#
#  id         :integer          not null, primary key
#  video      :text
#  created_at :datetime
#  updated_at :datetime
#  status     :text
#  job_id     :text
#

class InternalVideo < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  mount_uploader :video, VideoUploader

  after_create :create_videos

  # FIXME: there is too much copy/paste of zencoder stuff... need zencodeable module
  def create_videos
    job_params = {
      input: video.s3_url,
      outputs: [
        {
          audio_codec: 'aac',
          format:      'mp4',
          label:       'preview',
          quality:     '3',
          size:        '1280x720',
          speed:       '1',
          url:         video.preview.s3_url,
          video_codec: 'h264',

          thumbnails: {
            base_url: "s3://#{ENV['AWS_BUCKET_NAME']}/#{File.dirname(video.path)}/",
            filename: video.thumbnail.video_thumbnail_filename,
            format:   'png',
            label:    'main',
            number:   '1',
            size:     '400x400',
          },

          notifications: [
            internal_videos_zencoder_url,
          ],
        },
      ],
    }
    logger.debug "job_params: #{job_params.inspect}"

    UploadWorker.perform_in(2.seconds, 'start_video_processing', 'internal_video', id, job_params.to_json)
  end

  def start_video_processing(job_params)
    self.status = 'processing'

    response = Zencoder::Job.create(JSON.parse(job_params))
    self.job_id = response.body['id']

    save!
  end
end
