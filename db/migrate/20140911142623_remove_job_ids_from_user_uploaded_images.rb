class RemoveJobIdsFromUserUploadedImages < ActiveRecord::Migration
  def change
    remove_column :user_uploaded_images, :job_ids
  end
end
