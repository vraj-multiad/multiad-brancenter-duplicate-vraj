class AddExternalLinkToDlImage < ActiveRecord::Migration
  def change
    add_column :dl_images, :external_link, :string
  end
end
