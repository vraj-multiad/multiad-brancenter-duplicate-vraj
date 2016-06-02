json.array!(@social_media_accounts) do |social_media_account|
  json.extract! social_media_account, :expires_at, :oauth_refresh_token, :oauth_secret, :oauth_token, :profile_image, :profile_name, :user_id, :uid, :type
  json.url social_media_account_url(social_media_account, format: :json)
end