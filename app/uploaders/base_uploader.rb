class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWaveDirect::Uploader

  storage :fog

  def upload_form_data (legacy=false)
    if legacy
      self.use_action_status = false
      self.success_action_redirect = "#{APP_DOMAIN}/s3_result"
    else
      self.success_action_status = '201'
    end

    form_data = {
      'formData' => {
        acl: acl,
        'AwsAccessKeyId' => aws_access_key_id,
        key: key,
        policy: policy,
        signature: signature,
        :utf8 => '', # this doesn't work without hash rocket syntax... why?
      },
      url: direct_fog_url,
    }

    if legacy
      form_data['formData'][:success_action_redirect] = success_action_redirect
    else
      form_data['formData'][:success_action_status] = success_action_status
    end

    form_data
  end

  def full_cache_path
    "#{::Rails.root}/public/#{cache_dir}/#{cache_name}"
  end

  def s3_url
    "s3://#{ENV['AWS_BUCKET_NAME']}/#{self.full_filename}"
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/" + APP_ID
  end
end
