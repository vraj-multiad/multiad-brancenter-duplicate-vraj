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

class YoutubePost < SocialMediaPost
  def post! (url)
    youtube_account = YoutubeAccount.find(self.social_media_account_id)
    
    keywords = ['test']
    
    result = youtube_account.video_upload(
      File.open(download_file(url: url)),
      :title       => self.title,
      :description => self.description,
      :keywords    => keywords,
    )
    
    result.player_url
  end
end
