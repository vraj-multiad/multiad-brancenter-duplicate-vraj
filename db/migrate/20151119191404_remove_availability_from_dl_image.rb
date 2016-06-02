class RemoveAvailabilityFromDlImage < ActiveRecord::Migration
  def change
    remove_column :dl_images, :available_begin_at
    remove_column :dl_images, :available_end_at
  end
end
