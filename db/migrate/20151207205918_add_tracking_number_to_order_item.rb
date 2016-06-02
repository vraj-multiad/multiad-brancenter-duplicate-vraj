class AddTrackingNumberToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :tracking_number, :string
    add_column :order_items, :status, :string
  end
end
