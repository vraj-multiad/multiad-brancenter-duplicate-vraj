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

require 'httpclient'
require 'uri'

class FacebookAccount < SocialMediaAccount
  has_many :facebook_pages
  
  def get_connections (*params)
    koala do |client|
      client.get_connections('me', *params)
    end
  end
  
  def get_pages
    get_connections 'accounts', 'fields' => 'can_post,picture,name,access_token'
  end
  
  def logged_in?
    if @logged_in.nil?
      @logged_in = self.oauth_token && self.expires_at.to_i > Time.now.to_i
      self.queue_profile_update if @logged_in
    end
    
    @logged_in
  end
  
  def me
    if @me.nil?
      koala do |client|
        @me = client.get_object 'me'
      end
    end
    
    @me
  end
  
  def put_connections (*params)
    koala do |client|
      client.put_connections *params
    end
  end

  def put_picture (*params)
    koala do |client|
      client.put_picture *params
    end
  end
  
  def put_video (*params)
    koala do |client|
      client.put_video *params
    end
  end
  
  def update_profile_info
    self.profile_name = self.me['name']
    self.profile_image = 'https://graph.facebook.com/' + self.me['id'] + '/picture'
    self.save!
    
    pages = self.get_pages
    
    # create page record if it doesn't exist and update it
    pages.each do |page|
      facebook_page = FacebookPage.where(:facebook_account_id => self.id, :uid => page['id']).first_or_create
      facebook_page.profile_name  = page['name']
      facebook_page.profile_image = page['picture']['data']['url']
      facebook_page.uid   = page['id']
      facebook_page.oauth_token = page['access_token']
      facebook_page.expires_at = (Time.now + 60.days).to_i
      facebook_page.facebook_account_id = self.id
      facebook_page.save!
    end
    
    # destroy page records if they're not valid anymore
    FacebookPage.where(:facebook_account_id => self.id).each do |facebook_page|
      still_valid = false
      pages.each do |page|
        still_valid = true if page['id'] == facebook_page.uid
      end
      facebook_page.destroy unless still_valid
    end
  end
  
  def update_from_auth_hash (auth_hash)
    # wtf???
    if auth_hash['credentials']['expires']
      logger.debug 'expires'
      self.expires_at  = auth_hash['credentials']['expires_at']
    else
      logger.debug 'does not expire'
      self.expires_at = (Time.now + 60.days).to_i
    end
    
    self.oauth_token = auth_hash['credentials']['token']
    self.profile_image = 'https://graph.facebook.com/' + auth_hash['extra']['raw_info']['id'] + '/picture'
    self.profile_name  = auth_hash['extra']['raw_info']['name']
    self.uid     = auth_hash['uid']
    self.save!
  end
  
private
  
  def oauth_client
    if @oauth_client.nil?
      client = OAuth2::Client.new(
        ENV['FACEBOOK_APP_ID'],
        ENV['FACEBOOK_APP_SECRET'],
      )
      
      @oauth_client = OAuth2::AccessToken.new(client, self.oauth_token)
    end
    
    @oauth_client
  end
  
  def debug_token
    if @debug_token.nil?
      url = 'https://graph.facebook.com/debug_token'\
        + '?input_token=' + self.oauth_token\
        + '&access_token=' + ENV['FACEBOOK_APP_ACCESS_TOKEN']
      client = HTTPClient.new
      response = client.get URI.escape(url)
      
      @debug_token = JSON.parse response.body
    end
    
    @debug_token
  end
  
  def koala
    @koala ||= Koala::Facebook::API.new self.oauth_token
    yield @koala
  rescue Koala::Facebook::AuthenticationError => auth_error
    # if there is an auth error then log it and call logout
    # any credentials we may have are apperntly invalid
    logger.error "koala authentication error: #{auth_error.to_s}"
    self.logout!
    
    # this is still a fatal error the caller should handle
    raise auth_error
  end
  
end
