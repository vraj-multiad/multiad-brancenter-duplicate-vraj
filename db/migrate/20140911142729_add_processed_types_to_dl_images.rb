class AddProcessedTypesToDlImages < ActiveRecord::Migration
  def change
    add_column :dl_images, :processed_types, :text
  end
end
