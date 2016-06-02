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

class FacebookPage < FacebookAccount
  belongs_to :facebook_account
  
  def update_profile_info
    # do nothing, this is handled by the owning FacebookAccount class
  end
end
