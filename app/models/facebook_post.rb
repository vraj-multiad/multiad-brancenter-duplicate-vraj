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

class FacebookPost < SocialMediaPost
  def post! (url)
    facebook_account = SocialMediaAccount.find(self.social_media_account_id)
    logger.debug 'url: ' + url
    success = nil;
    post_type = 'image'
    share_link = ''

    if self.asset_type == 'UserUploadedImage'
      uui = UserUploadedImage.find(self.asset_id)
      if uui.upload_type == 'library_video'
        post_type = 'video'
        logger.debug 'posting video'
      end
    end
    if self.asset_type == 'DlImage'
      dli = DlImage.find(self.asset_id)
      if dli.video?
        post_type = 'video'
        logger.debug 'posting video'
      end
    end
    if self.asset_type == 'SharedPage'
      post_type = 'link'
      sp = SharedPage.find(self.asset_id)
      share_link = sp.share_link
      logger.debug 'posting link ' + share_link.to_s
    end

    case post_type
    when 'image'
      result = facebook_account.put_picture(
        File.open(download_file(url: url)),
        '', # mime type
        {
          :message => self.description,
        },
        'me',
      )
      success = 'https://www.facebook.com/photo.php?fbid=' + result['id']
    when 'video'
      result = facebook_account.put_video(
        File.open(download_file(url: url)),
        '', # mime type
        {
          :title       => self.title,
          :description => self.description,
        },
        'me',
      )
      success = 'https://www.facebook.com/photo.php?v=' + result['id']
    when 'link'
      result = facebook_account.put_connections(
        'me',
        'feed',
        {
          :message => self.description + ' ' + share_link.to_s,
        }
      )
      success = 'https://www.facebook.com/'      
    end


    
    return success
  end
end
