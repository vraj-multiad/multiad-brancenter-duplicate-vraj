class AddS3PollCount < ActiveRecord::Migration
  def change
    add_column :user_uploaded_images, :s3_poll_count, :integer, default: 0

    add_column :dl_images, :s3_poll_count, :integer, default: 0
  end
end
