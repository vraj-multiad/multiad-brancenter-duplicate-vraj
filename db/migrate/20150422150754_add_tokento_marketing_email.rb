class AddTokentoMarketingEmail < ActiveRecord::Migration
  def change
    add_column :marketing_emails, :token, :string
  end
end
