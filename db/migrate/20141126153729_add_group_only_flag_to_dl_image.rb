class AddGroupOnlyFlagToDlImage < ActiveRecord::Migration
  def change
    add_column :dl_images, :group_only_flag, :boolean, default: false
  end
end
