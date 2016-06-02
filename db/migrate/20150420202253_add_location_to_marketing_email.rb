class AddLocationToMarketingEmail < ActiveRecord::Migration
  def change
    add_column :marketing_emails, :location, :string
  end
end
