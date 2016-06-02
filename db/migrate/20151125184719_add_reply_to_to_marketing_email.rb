class AddReplyToToMarketingEmail < ActiveRecord::Migration
  def change
    add_column :marketing_emails, :reply_to, :string
  end
end
