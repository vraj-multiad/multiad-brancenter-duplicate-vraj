class ChangeDefaultValueToUser < ActiveRecord::Migration
  def change
    change_column :users, :license_agreement_flag, :boolean, default: false
    change_column :users, :update_profile_flag, :boolean, default: false
    change_column :users, :same_billing_shipping, :boolean, default: false
    change_column :users, :activated, :boolean, default: false
  end
end
