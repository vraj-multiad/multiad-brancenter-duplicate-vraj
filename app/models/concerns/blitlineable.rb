module Blitlineable
  extend ActiveSupport::Concern
  include S3able

  BLITLINE_TYPES = {
    thumbnail: {
      name: 'resize_to_fit',
      params: {
        width: '200',
      },
    },
    preview: {
      name: 'resize_to_fit',
      # params: '800x800',
      params: {
        width: '800',
        height: '800',
      },
    },
    jpg: {
      name: 'convert_command',
      params: {},
    },
    png: {
      name: 'convert_command',
      params: {},
    },
  }

  # DO NOT CHANGE THESE VALUES HERE
  # CUSTOMIZE THEM IN config/application.yml OR heroku config
  BLITLINE_S3_MAX_POLLS        = ENV['BLITLINE_S3_MAX_POLLS']        ? ENV['BLITLINE_S3_MAX_POLLS'].to_i             : 24
  BLITLINE_S3_MOVE_MAX_RETRIES = ENV['BLITLINE_S3_MOVE_MAX_RETRIES'] ? ENV['BLITLINE_S3_MOVE_MAX_RETRIES'].to_i      : 60
  BLITLINE_S3_POLL_INTERVAL    = ENV['BLITLINE_S3_POLL_INTERVAL']    ? ENV['BLITLINE_S3_POLL_INTERVAL'].to_i.seconds : 10.seconds

  included do
    after_initialize :set_serialized_defaults
    has_many :media_jobs, as: :mediajobable
    serialize :processed_types, JSON

    def add_processed_type (type)
      type = type.to_s
      processed_types << type unless processed_types.include?(type)
    end

    def blitline_complete?
      processed_types.uniq.sort == BLITLINE_TYPES.keys.sort.map{|x| x.to_s}
    end

    def blitline_complete!
      return unless status == 'processing'

      case upload_type
      when 'logo', 'ac_image'
        self.status = 'complete'
      else
        self.status = 'processed'
      end

      if pdf?
        BLITLINE_TYPES.keys.each do |type|
          unless s3_key_exists?(desired_key(type))
            move_success = s3_move(pdf_key(type), desired_key(type), BLITLINE_S3_MOVE_MAX_RETRIES, false)
            unless move_success
              logger.error "failed to move type #{type}"
              self.status = 'failed'
              break
            end
          end
        end
      end

      save!
    end

    def create_blitline_type (blitline_type)
      type_hash = BLITLINE_TYPES[blitline_type]

      job_params = {
        application_id: ENV['BLITLINE_APP_ID'],
        postback_url: blitline_callback_url,
        src: image_uploader.url,
        src_data: {
          colorspace: 'rgb',
        },
        functions: [
          {
            name: type_hash[:name],
            params: type_hash[:params],
            save: {
              save_profiles: true,
              image_identifier: "#{id.to_s}-#{blitline_type}",
              s3_destination: {
                bucket: ENV['AWS_BUCKET_NAME'],
                key: image_uploader.send(blitline_type).full_filename,
              },
            },
          },
        ],
      }

      if pdf?
        job_params[:src_type] = 'burst_pdf'
        job_params[:src_data][:pages] = [0]
      end

      job_params[:src_data][:density] = 300 if File.extname(filename) == '.eps'

      logger.debug "job_params: #{job_params.to_yaml}"
      UploadWorker.perform_in(2.seconds, 'start_image_processing', self.class.to_s, id, blitline_type, job_params.to_json)
    end

    def create_images
      self.status = 'processing'
      save!

      BLITLINE_TYPES.keys.each do |blitline_type|
        create_blitline_type(blitline_type)
      end

      UploadWorker.perform_in(BLITLINE_S3_POLL_INTERVAL, 'poll_s3_for_blitline_success', self.class.to_s, id)
    end

    def desired_key (type)
      image_uploader.send(type.to_sym).full_filename
    end

    def pdf?
      File.extname(image_uploader.file.path).downcase == '.pdf'
    end

    def pdf_key (type, page=0)
      usual_key = desired_key(type)
      basename = File.basename(usual_key, File.extname(usual_key))
      basename += '__' + page.to_s
      file_name = basename + File.extname(usual_key)
      File.join(File.dirname(usual_key), file_name)
    end

    def poll_s3_for_blitline_success
      return unless status == 'processing'

      ActiveRecord::Base.connection_pool.with_connection do
        self.class.transaction do
          lock!
          self.s3_poll_count += 1

          BLITLINE_TYPES.keys.each do |type|
            next if processed_types.include?(type)

            key = pdf? ? pdf_key(type) : desired_key(type)
            add_processed_type(type) if s3_key_exists?(key)
          end

          if blitline_complete?
            blitline_complete!
          else
            if s3_poll_count < BLITLINE_S3_MAX_POLLS
              UploadWorker.perform_in(BLITLINE_S3_POLL_INTERVAL, 'poll_s3_for_blitline_success', self.class.to_s, id)
            else
              self.status = 'failed'
            end
            save!
          end
        end
      end
    end

    def start_image_processing (blitline_type, job_params)
      blitline = Blitline.new
      blitline.add_job_via_hash(JSON.parse(job_params))
      result = blitline.post_jobs
      logger.debug "result: #{result.inspect}"

      job_id = result['results'][0]['group_completion_job_id'] || result['results'][0]['job_id']
      MediaJob.create!(
        api: 'blitline',
        mediajobable: self,
        output_type: blitline_type,
        job_id: job_id,
      )
    rescue RuntimeError => ex
      logger.error ex
      logger.error ex.backtrace.to_yaml
      logger.error job_params
      self.status = 'failed'
      save
    end

    private

    def set_serialized_defaults
      self.processed_types ||= []
    end
  end

  module ClassMethods
    def update_blitline_status (results)
      results = JSON.parse(results)

      logger.debug 'update_blitline_status'
      logger.debug results.inspect

      media_job = MediaJob.blitline.find_by(job_id: results['job_id'])
      image = media_job.mediajobable

      if image.created_at.today?
        ActiveRecord::Base.connection_pool.with_connection do
          transaction do
            image.lock!

            if results['error']
              logger.error 'error reported by blitline'
              image.status = 'failed'
            end

            image.add_processed_type(media_job.output_type) if image.status == 'processing'

            if image.blitline_complete?
              image.blitline_complete!
            else
              image.save!
            end
          end
        end
      else
        Rails.logger.warn "Not updating blitline status for #{image.id} - not updated today"
      end
    end
  end
end
