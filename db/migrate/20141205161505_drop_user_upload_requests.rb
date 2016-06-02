class DropUserUploadRequests < ActiveRecord::Migration
  def change
    drop_table :user_upload_requests
  end
end
