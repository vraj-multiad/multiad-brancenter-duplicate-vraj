class AddMobileNumberToUser < ActiveRecord::Migration
  def change
    add_column :users, :mobile_number, :string
    add_column :users, :website, :string
    add_column :users, :company_name, :string
  end
end
