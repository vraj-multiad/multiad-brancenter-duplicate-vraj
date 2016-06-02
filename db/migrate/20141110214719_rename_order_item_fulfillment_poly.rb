class RenameOrderItemFulfillmentPoly < ActiveRecord::Migration
  def change
    rename_column :order_items, :fulfillable_type, :orderable_type
    rename_column :order_items, :fulfillable_id, :orderable_id
  end
end
