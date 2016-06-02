class AddIsDownloadableAndDescriptionToDlImage < ActiveRecord::Migration
  def change
    add_column :dl_images, :is_downloadable, :boolean
    add_column :dl_images, :description, :text
    add_column :dl_images, :available_begin_at, :datetime
    add_column :dl_images, :available_end_at, :datetime
    add_column :user_uploaded_images, :is_downloadable, :boolean
    add_column :user_uploaded_images, :description, :text
  end
end
