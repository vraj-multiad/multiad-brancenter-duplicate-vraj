class CreateDlImageGroupImages < ActiveRecord::Migration
  def change
    create_table :dl_image_group_images, id: false do |t|
      t.belongs_to :dl_image_group
      t.belongs_to :dl_image
      # t.integer :dl_image_group_id
      # t.integer :dl_image_id
    end
  end
end
