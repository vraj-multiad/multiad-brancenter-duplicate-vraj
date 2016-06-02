class AddProcessedTypesAndJobIdsToUserUploadedImages < ActiveRecord::Migration
  def change
    add_column :user_uploaded_images, :processed_types, :text
    add_column :user_uploaded_images, :job_ids, :text
  end
end
