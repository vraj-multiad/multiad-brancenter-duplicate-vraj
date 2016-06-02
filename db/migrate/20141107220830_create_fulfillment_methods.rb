class CreateFulfillmentMethods < ActiveRecord::Migration
  def change
    create_table :fulfillment_methods do |t|
      t.string :name
      t.string :title

      t.timestamps
    end
  end
end
