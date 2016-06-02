class AddMinQuantityToFulfillmentItem < ActiveRecord::Migration
  def change
    add_column :fulfillment_items, :min_quantity, :integer
    add_column :fulfillment_items, :max_quantity, :integer
  end
end
