class AddExternalLinkLabelToDlImage < ActiveRecord::Migration
  def change
    add_column :dl_images, :external_link_label, :string
  end
end
