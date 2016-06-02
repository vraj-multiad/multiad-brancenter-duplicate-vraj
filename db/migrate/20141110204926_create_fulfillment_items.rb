class CreateFulfillmentItems < ActiveRecord::Migration
  def change
    create_table :fulfillment_items do |t|
      t.string :fulfillable_type
      t.integer :fulfillable_id
      t.integer :fulfillment_method_id
      t.text :price_schedule, default: {}
      t.decimal :price_per_unit
      t.decimal :weight_per_unit
      t.boolean :taxable, default: true
      t.text :description

      t.timestamps
    end
  end
end
