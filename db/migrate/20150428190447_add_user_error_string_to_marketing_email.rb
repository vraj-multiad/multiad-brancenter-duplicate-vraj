class AddUserErrorStringToMarketingEmail < ActiveRecord::Migration
  def change
    add_column :marketing_emails, :user_error_string, :string
  end
end
