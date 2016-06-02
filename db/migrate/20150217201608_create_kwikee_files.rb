class CreateKwikeeFiles < ActiveRecord::Migration
  def change
    create_table :kwikee_files do |t|
      t.integer :kwikee_product_id
      t.integer :kwikee_asset_id
      t.text :extension
      t.string :url

      t.timestamps
    end
  end
end
