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

class TwitterAccount < SocialMediaAccount
  def logged_in?
    if @logged_in.nil?
      @logged_in = self.oauth_token && self.oauth_secret
      self.queue_profile_update if @logged_in
    end
    
    @logged_in
  end
  
  def current_user
    # calling twitter_client.current_user is aliased to hitting the verify_credentials api call
    # which is severly rate limited
    # by storing the user id we can make this call which is less restricted by a factor of more than 10
    if @current_user.nil?
      twitter_client do |client|
        @current_user = client.user self.uid.to_i
      end
    end
    @current_user
  end
  
  def update (*params)
    twitter_client do |client|
      client.update *params
    end
  end
  
  def update_profile_info
    self.profile_name  = self.current_user.screen_name
    self.profile_image = self.current_user.profile_image_url_https
    self.save
  end
  
  def update_from_auth_hash (auth_hash)
    self.oauth_secret  = auth_hash['credentials']['secret']
    self.oauth_token   = auth_hash['credentials']['token']
    self.profile_image = auth_hash['extra']['raw_info']['profile_image_url_https']
    self.profile_name  = auth_hash['extra']['raw_info']['screen_name']
    self.uid       = auth_hash['uid']
    self.save!
  end
  
  def update_with_media (*params)
    twitter_client do |client|
      client.update_with_media *params
    end
  end
  
private
  
  def oauth_client
    if @oauth_client.nil?
      consumer = OAuth::Consumer.new(
        ENV['TWITTER_CONSUMER_KEY'],
        ENV['TWITTER_CONSUMER_SECRET'],
      )
      
      @oauth_client = OAuth::AccessToken.new(consumer, self.oauth_token, self.oauth_secret)
    end
    
    @oauth_client
  end
  
  def twitter_client
    @twitter_client ||= Twitter::Client.new(
      :oauth_token        => self.oauth_token,
      :oauth_token_secret => self.oauth_secret,
    )
    yield @twitter_client
  rescue Twitter::Error::Forbidden => forbidden
    # if there is an auth error then log it and call logout
    # any credentials we may have are apperntly invalid
    logger.error "twitter_client forbidden error: #{forbidden.to_s}"
    
    # this is a crappy hack
    # but it's also really crappy to get forbidden back for this...
    self.logout! unless forbidden.to_s == 'Status is over 140 characters.'
      
    # this is still a fatal error the caller should handle
    raise forbidden
  end
  
end
