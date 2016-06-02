# == Schema Information
#
# Table name: social_media_accounts
#
#  id                  :integer          not null, primary key
#  expires_at          :integer
#  oauth_refresh_token :text
#  oauth_secret        :text
#  oauth_token         :text
#  profile_image       :string(255)
#  profile_name        :string(255)
#  user_id             :integer
#  uid                 :string(255)
#  type                :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  facebook_account_id :integer
#  last_used           :datetime
#

class SocialMediaAccount < ActiveRecord::Base
  belongs_to :user
  validates :type, uniqueness: { scope: [ :user_id, :uid ] }

  def oauth_token
    token = super
    token = AES.decrypt(token, ENV['OAUTH_AES_KEY']) unless token.nil? || token == ''
  end

  def oauth_token= (token)
    token = AES.encrypt(token, ENV['OAUTH_AES_KEY']) unless token.nil? || token == ''
    super(token)
  end

  def oauth_secret
    token = super
    token = AES.decrypt(token, ENV['OAUTH_AES_KEY']) unless token.nil? || token == ''
  end

  def oauth_secret= token
    logger.debug 'token'
    logger.debug token.to_s
    logger.debug 'env oauth aes key'
    logger.debug ENV['OAUTH_AES_KEY'].to_s

    token = AES.encrypt(token, ENV['OAUTH_AES_KEY']) unless token.nil? || token == ''
    super(token)
  end

  def oauth_refresh_token
    token = super
    token = AES.decrypt(token, ENV['OAUTH_AES_KEY']) unless token.nil? || token == ''
  end

  def oauth_refresh_token= (token)
    token = AES.encrypt(token, ENV['OAUTH_AES_KEY']) unless token.nil? || token == ''
    super(token)
  end

  # idea is to call this from any method gets profile info
  # instance variable guarantees it never queues a job more than once per request
  # and profile info is always immediately available and never out of sync for more than one request
  # this obviously implies that all child classes must implement a update_profile_info function
  def queue_profile_update
#     logger.debug "called by #{caller.join("\n")}"
    unless @profile_update_queued
      logger.debug 'queueing update_profile_info'
      SocialMediaWorker.perform_async('update_profile_info', 'social_media_account', id)
      @profile_update_queued = true
    end
  end

  def profile_name
    if @profile_name.nil?
      if self.logged_in?
        @profile_name = super
        self.queue_profile_update
      else
        @profile_name = ''
      end
    end

    @profile_name
  end

  def profile_image
    if @profile_image.nil?
      if self.logged_in?
        @profile_image = super
        self.queue_profile_update
      else
        @profile_image = ''
      end
    end

    @profile_image
  end

  def logout!
    self.oauth_token = nil
    self.oauth_secret = nil
    self.oauth_refresh_token = nil
    self.expires_at = nil
    self.uid = nil
    self.profile_name = nil
    self.profile_image = nil
    self.save!
  end
end
