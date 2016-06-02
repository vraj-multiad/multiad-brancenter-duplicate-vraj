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

class TwitterPost < SocialMediaPost
  def post! (url)
    twitter_account = TwitterAccount.find(self.social_media_account_id)

    share_link = ''
    post_type = 'standard'
    if self.asset_type == 'SharedPage'
      post_type = 'link'
      sp = SharedPage.find(self.asset_id)
      share_link = sp.share_link
      logger.debug 'posting link ' + share_link.to_s
    end

    if post_type == 'standard'
      result = twitter_account.update_with_media(self.description, File.open(download_file(url: url)))
    else
      result = twitter_account.update(self.description + ' ' + share_link)
    end

    'https://twitter.com/' + twitter_account.profile_name + '/status/' + result['attrs'][:id_str]
  end
end
