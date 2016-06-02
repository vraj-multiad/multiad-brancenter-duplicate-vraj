class AddBillCostCenterToOrder < ActiveRecord::Migration
  def change
    rename_column :users, :bill_external_id, :cost_center
    add_column :orders, :bill_cost_center, :string
    add_column :orders, :bill_external_account_id, :string
  end
end
