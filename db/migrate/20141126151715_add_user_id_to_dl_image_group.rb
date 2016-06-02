class AddUserIdToDlImageGroup < ActiveRecord::Migration
  def change
    add_column :dl_image_groups, :user_id, :integer
  end
end
