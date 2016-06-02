class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.integer :order_id
      t.string :fulfillable_type
      t.integer :fulfillable_id
      t.string :vendor_item_number
      t.text :description
      t.integer :quantity
      t.decimal :unit_price
      t.decimal :item_total

      t.timestamps
    end
  end
end
