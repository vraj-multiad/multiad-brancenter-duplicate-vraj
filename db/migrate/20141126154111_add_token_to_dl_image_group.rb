class AddTokenToDlImageGroup < ActiveRecord::Migration
  def change
    add_column :dl_image_groups, :token, :string
  end
end
