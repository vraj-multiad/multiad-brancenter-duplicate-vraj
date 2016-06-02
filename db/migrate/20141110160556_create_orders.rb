class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.integer :fulfillment_method_id
      t.string :bill_first_name
      t.string :bill_last_name
      t.string :bill_address_1
      t.string :bill_address_2
      t.string :bill_city
      t.string :bill_state
      t.string :bill_zip_code
      t.string :bill_phone_number
      t.string :bill_fax_number
      t.string :bill_email_address
      t.text :bill_comments
      t.string :bill_method
      t.string :ship_first_name
      t.string :ship_last_name
      t.string :ship_address_1
      t.string :ship_address_2
      t.string :ship_city
      t.string :ship_state
      t.string :ship_zip_code
      t.string :ship_phone_number
      t.string :ship_fax_number
      t.string :ship_email_address
      t.text :ship_comments
      t.string :ship_method
      t.string :vendor_po_number
      t.string :status
      t.string :tracking_number
      t.text :order_comments
      t.string :currency_type
      t.decimal :sub_total
      t.decimal :tax
      t.decimal :handling
      t.decimal :total

      t.timestamps
    end
  end
end
