class AddStatusToMarketingEmail < ActiveRecord::Migration
  def change
    add_column :marketing_emails, :status, :string
    add_column :marketing_emails, :error_string, :text
  end
end
