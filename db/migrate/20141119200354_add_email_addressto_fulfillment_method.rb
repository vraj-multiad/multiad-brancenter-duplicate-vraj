class AddEmailAddresstoFulfillmentMethod < ActiveRecord::Migration
  def change
    add_column :fulfillment_methods, :email_address, :string
  end
end
