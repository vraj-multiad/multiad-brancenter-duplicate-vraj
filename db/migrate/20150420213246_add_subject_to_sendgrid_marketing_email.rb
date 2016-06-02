class AddSubjectToSendgridMarketingEmail < ActiveRecord::Migration
  def change
    add_column :marketing_emails, :subject, :string
  end
end
