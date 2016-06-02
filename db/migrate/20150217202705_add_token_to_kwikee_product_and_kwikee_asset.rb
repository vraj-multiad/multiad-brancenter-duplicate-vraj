class AddTokenToKwikeeProductAndKwikeeAsset < ActiveRecord::Migration
  def change
    add_column :kwikee_products, :token, :string
    add_column :kwikee_assets, :token, :string
  end
end
