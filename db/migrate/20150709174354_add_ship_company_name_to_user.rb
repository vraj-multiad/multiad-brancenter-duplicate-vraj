class AddShipCompanyNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :ship_company_name, :string
    add_column :orders, :bill_company_name, :string
    add_column :orders, :ship_company_name, :string
  end
end
