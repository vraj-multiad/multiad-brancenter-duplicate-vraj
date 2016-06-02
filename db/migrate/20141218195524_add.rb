class Add < ActiveRecord::Migration
  def change
    add_column :internal_videos, :job_id, :text
  end
end
