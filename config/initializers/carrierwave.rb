CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                        # required
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],                        # required
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],                        # required
  }
  config.permissions = 0666
  config.directory_permissions = 0777
  config.fog_directory  = ENV['AWS_BUCKET_NAME']                  # required
  config.fog_public     = false                                   # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
  config.max_file_size = 5.gigabytes # videos could be large?
  config.use_action_status = true
end
