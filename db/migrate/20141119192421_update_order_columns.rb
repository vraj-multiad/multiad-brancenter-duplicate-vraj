class UpdateOrderColumns < ActiveRecord::Migration
  def change
    rename_column :orders, :ship_method, :shipping_method
    add_column :orders, :shipping, :decimal
  end
end
