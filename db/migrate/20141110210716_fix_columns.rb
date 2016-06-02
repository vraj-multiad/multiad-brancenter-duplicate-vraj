class FixColumns < ActiveRecord::Migration
  def change
    change_column :fulfillment_items, :price_schedule, :text, default: '{}'
    add_column :order_items, :fulfillment_item_id, :integer
  end
end
