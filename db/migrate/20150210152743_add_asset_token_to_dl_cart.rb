class AddAssetTokenToDlCart < ActiveRecord::Migration
  def change
    add_column :dl_carts, :asset_token, :string
  end
end
