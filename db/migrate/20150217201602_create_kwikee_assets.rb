class CreateKwikeeAssets < ActiveRecord::Migration
  def change
    create_table :kwikee_assets do |t|
      t.integer :kwikee_product_id
      t.integer :asset_id
      t.text :promotion
      t.text :asset_type
      t.text :version
      t.text :view

      t.timestamps
    end
  end
end
