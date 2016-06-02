class AddFromNameToMarketingEmail < ActiveRecord::Migration
  def change
    add_column :marketing_emails, :from_name, :string
    add_column :marketing_emails, :from_address, :string
  end
end
