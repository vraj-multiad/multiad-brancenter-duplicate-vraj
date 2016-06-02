class AddPublishDatesToDlImage < ActiveRecord::Migration
  def change
    add_column :ac_creator_templates, :publish_at, :datetime
    add_column :ac_creator_templates, :unpublish_at, :datetime
    add_column :ac_images, :publish_at, :datetime
    add_column :ac_images, :unpublish_at, :datetime
    add_column :ac_texts, :publish_at, :datetime
    add_column :ac_texts, :unpublish_at, :datetime
    add_column :dl_images, :publish_at, :datetime
    add_column :dl_images, :unpublish_at, :datetime
  end
end
