class AddVendorItemNumberToOrderItem < ActiveRecord::Migration
  def change
    remove_column :orders, :Order, :string
    add_column :order_items, :Order, :string
  end
end
