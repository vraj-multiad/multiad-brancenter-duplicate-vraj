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

class YoutubeAccount < SocialMediaAccount
  
  def logged_in?
    if @logged_in.nil?
      @logged_in = self.oauth_token
      self.queue_profile_update if @logged_in
    end
    
    @logged_in
  end
  
  def profile
    if @profile.nil?
      youtube_client do |client|
        @profile = client.profile
      end
    end
    @profile
  end
  
  def update_from_auth_hash (auth_hash)
    self.expires_at          = auth_hash['credentials']['expires_at']
    self.oauth_refresh_token = auth_hash['credentials']['refresh_token']
    self.oauth_token         = auth_hash['credentials']['token']
    self.profile_image       = auth_hash['extra']['user_hash']['media$thumbnail']['url']
    self.profile_name        = auth_hash['extra']['user_hash']['title']['$t'] # not sure how great this is
    self.uid             = auth_hash['uid'].split('/').pop
    self.save!
  end
  
  def update_profile_info
    self.profile_name  = self.profile.username_display
    self.profile_image = self.profile.avatar
    self.save!
  end
  
  def video_upload (*params)
    youtube_client do |client|
      client.video_upload *params
    end
  end
  
private
  
  def oauth_client
    if @oauth_client.nil?
      client = OAuth2::Client.new(
        ENV['YOUTUBE_CLIENT_ID'],
        ENV['YOUTUBE_CLIENT_SECRET'],
      )
      
      @oauth_client = OAuth2::AccessToken.new(client, self.oauth_token)
    end
    
    @oauth_client
  end
  
  def youtube_client
    if @youtube_client.nil?
      @youtube_client = YouTubeIt::OAuth2Client.new(
        client_access_token: self.oauth_token,
        client_refresh_token: self.oauth_refresh_token,
        client_id: ENV['YOUTUBE_CLIENT_ID'],
        client_secret: ENV['YOUTUBE_CLIENT_SECRET'],
        client_token_expires_at: self.expires_at,
        dev_key: ENV['YOUTUBE_API_KEY'],
      )
      @youtube_client.refresh_access_token!
    end
    yield @youtube_client
  rescue OAuth2::Error => auth_error
    # if there is an auth error then log it and call logout
    # any credentials we may have are apperntly invalid
    logger.error "youtube_client auth_error: #{auth_error.to_s}"
    self.logout!
    
    # this is still a fatal error the caller should handle
    # annoying html in oauth2 exception message...
    raise 'OAuth2 error'
  end
  
end
