class AddDefaultAssetToKwikeeProduct < ActiveRecord::Migration
  def change
    add_column :kwikee_products, :default_kwikee_asset_id, :integer
    add_column :kwikee_products, :default_kwikee_file_id, :integer
  end
end
