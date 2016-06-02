class CreateDlImageGroups < ActiveRecord::Migration
  def change
    create_table :dl_image_groups do |t|
      t.integer :main_dl_image_id
      t.string :name
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
