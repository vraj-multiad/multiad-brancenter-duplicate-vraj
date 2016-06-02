class RenameDlImageGroupImagesToDlImageGroupDlImages < ActiveRecord::Migration
  def change
    rename_table :dl_image_group_images, :dl_image_groups_dl_images
  end
end
