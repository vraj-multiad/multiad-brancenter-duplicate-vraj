class RenameMediaJobColumns < ActiveRecord::Migration
  def change
    rename_column :media_jobs, :model, :mediajobable_type
    rename_column :media_jobs, :model_id, :mediajobable_id
  end
end
