class AddStatusToInternalVideos < ActiveRecord::Migration
  def change
    add_column :internal_videos, :status, :text
  end
end
