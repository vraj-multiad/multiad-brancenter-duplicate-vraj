class AddDefaultToIsDownloadable < ActiveRecord::Migration
  def change
    change_column :dl_images, :is_downloadable, :boolean, default: true
    change_column :user_uploaded_images, :is_downloadable, :boolean, default: true
  end
end
