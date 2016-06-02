# == Schema Information
#
# Table name: social_media_posts
#
#  id                      :integer          not null, primary key
#  social_media_account_id :integer
#  description             :text
#  finished_at             :datetime
#  error                   :text
#  type                    :string(255)
#  asset_id                :integer
#  title                   :string(255)
#  success                 :text
#  created_at              :datetime
#  updated_at              :datetime
#  asset_type              :string(255)
#  post_as                 :string(255)
#  email_subject           :string(255)
#

class SocialMediaPost < ActiveRecord::Base
  belongs_to :social_media_account

  def download_file(url: nil)
    raise ArgumentException, 'url not passed' unless url

    uri = URI(url)

    original_file_name = uri.path.split('/').last
    logger.debug "original_file_name: #{original_file_name}"

    # technically this is only right if there is one and only one '.' that is immediately before the file extension
    # i don't think it really matters
    base_file_name = original_file_name.split('.').first
    logger.debug "base_file_name: #{base_file_name}"
    file_extension = original_file_name.split('.').last
    logger.debug "file_extension: #{file_extension}"

    hex = SecureRandom.hex
    logger.debug "hex: #{hex}"

    saved_file_path = "#{Rails.root}" + '/tmp/' + base_file_name + hex + '.' + file_extension
    logger.debug "saved_file_path #{saved_file_path}"

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri

      http.request request do |response|
        File.open(saved_file_path, 'wb') do |file|
          response.read_body do |chunk|
            file.write chunk
          end
        end
      end
    end

    saved_file_path
  end

  def post
    asset = nil

    ## need case for each supported type
    case asset_type
    when 'SharedPage'
      asset = SharedPage.find(asset_id)
    when 'DlImage'
      asset = DlImage.find(asset_id)
    when 'UserUploadedImage'
      asset = UserUploadedImage.find(asset_id)
    end
    self.success = post!(asset.share_url)
    self.finished_at = Time.now
    save!
  rescue StandardError => ex
    self.finished_at = Time.now
    self.error = ex.to_s # +  "\n" + exception.backtrace.to_s
    save!
  end
end
