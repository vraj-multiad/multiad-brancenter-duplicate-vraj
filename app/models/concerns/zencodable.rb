module Zencodable
  extend ActiveSupport::Concern

  def create_videos
    job_params = {
      input: image_uploader.s3_url,
      outputs: [
        {  # stream
          audio_codec: 'aac',
          format:      'mp4',
          label:       'preview',
          quality:     '3', # not a fan of arbitrary quality values, hopefully zencoder knows what they're doing
          size:        '1280x720',
          speed:       '1', # also arbitrary... use veryslow preset instead?
          url:         image_uploader.preview.s3_url,
          video_codec: 'h264',

          thumbnails: {
            base_url: 's3://' + ENV['AWS_BUCKET_NAME'] + '/' + File.dirname(image_uploader.path) + '/',
            filename: image_uploader.thumbnail.video_thumbnail_filename,
            format: 'png',
            label:  'main',
            number: '1',
            size:   '400x400',
          },

          notifications: [
            zencoder_callback_url,
          ],
        },
        { # wmv
          # audio_codec: 'aac',
          format:      'wmv',
          label:       'wmv',
          # quality:     '3', # not a fan of arbitrary quality values, hopefully zencoder knows what they're doing
          size:        '1920x1080',
          speed:       '1', # also arbitrary... use veryslow preset instead?
          url:         image_uploader.wmv.s3_url,
          video_codec: 'wmv',

          notifications: [
            zencoder_callback_url,
          ],
        },
        { # mov
          # audio_codec: 'aac',
          format:      'mov',
          label:       'mov',
          # quality:     '3', # not a fan of arbitrary quality values, hopefully zencoder knows what they're doing
          size:        '1920x1080',
          speed:       '1', # also arbitrary... use veryslow preset instead?
          url:         image_uploader.mov.s3_url,
          video_codec: 'h264',

          notifications: [
            zencoder_callback_url,
          ],
        },
      ],
    }

    if ENV['ZENCODER_TRANSCODE_ORIGINAL']
      job_params[:outputs] << {
        audio_codec: ENV['ZENCODER_TRANSCODE_ORIGINAL_AUDIO_CODEC'] || 'aac',
        format:      ENV['ZENCODER_TRANSCODE_ORIGINAL_FORMAT'] || 'mp4',
        label:       'original',
        size:        ENV['ZENCODER_TRANSCODE_ORIGINAL_SIZE'] || '1920x1080',
        speed:       1,
        url:         image_uploader.original.s3_url,
        video_codec: ENV['ZENCODER_TRANSCODE_ORIGINAL_VIDEO_CODEC'] || 'h264',

        notifications: [
          zencoder_callback_url,
        ],
      }
    end

    logger.debug "job_params: #{job_params.to_yaml}"

    UploadWorker.perform_in(2.seconds, 'start_video_processing', self.class.to_s, id, job_params.to_json)
  end

  def start_video_processing(job_params)
    self.status = 'processing'

    response = Zencoder::Job.create(JSON.parse(job_params))
    self.job_id = response.body['id']

    save!
  end
end
