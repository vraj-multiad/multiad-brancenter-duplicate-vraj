class AddVendorItemNumberToOrderItem2 < ActiveRecord::Migration
  def change
    remove_column :order_items, :Order, :string
  end
end
