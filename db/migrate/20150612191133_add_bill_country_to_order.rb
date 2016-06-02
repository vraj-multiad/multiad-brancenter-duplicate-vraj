class AddBillCountryToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :bill_country, :string
    add_column :orders, :ship_country, :string
    add_column :orders, :comments, :text
    add_column :order_items, :comments, :text
    add_column :users, :external_account_id, :string
    add_column :users, :bill_external_id, :string
    add_column :fulfillment_items, :vendor_item_id, :string
  end
end
