class AddEmailSubjectToSocialMediaPost < ActiveRecord::Migration
  def change
    add_column :social_media_posts, :email_subject, :string
  end
end
