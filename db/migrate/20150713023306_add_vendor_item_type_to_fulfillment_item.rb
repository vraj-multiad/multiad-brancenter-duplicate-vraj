class AddVendorItemTypeToFulfillmentItem < ActiveRecord::Migration
  def change
    add_column :fulfillment_items, :item_category, :string
    add_column :fulfillment_items, :item_type, :string
  end
end
