module S3able
  extend ActiveSupport::Concern

  included do
    def s3
      @s3 ||= AWS::S3.new
    end

    def s3_bucket
      s3.buckets[ENV['AWS_BUCKET_NAME']]
    end

    def s3_key_exists? (key)
      s3_object(key).exists?
    end

    def s3_move (from_key, to_key, retries=0, raise_error=true)
      obj = s3_object(from_key)
      moved_successfully = true

      tries = 0
      begin
        obj.move_to(to_key)
      rescue AWS::S3::Errors::NoSuchKey => ex
        tries += 1
        if tries < retries
          sleep 1
          retry
        else
          logger.error "Failed to move s3 object after #{tries.to_s + ' try'.pluralize(tries)}, giving up."
          raise ex if raise_error
          moved_successfully = false
        end
      end

      moved_successfully
    end

    def s3_object (key)
      s3_bucket.objects[key]
    end
  end
end
