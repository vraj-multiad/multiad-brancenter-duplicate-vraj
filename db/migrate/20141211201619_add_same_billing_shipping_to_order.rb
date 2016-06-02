class AddSameBillingShippingToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :same_billing_shipping, :boolean
  end
end
