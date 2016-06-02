class RenameFileToVideo < ActiveRecord::Migration
  def change
    rename_column :internal_videos, :file, :video
  end
end
