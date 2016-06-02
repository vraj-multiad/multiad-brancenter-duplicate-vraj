class CreateMarketingEmailRecipients < ActiveRecord::Migration
  def change
    create_table :marketing_email_recipients do |t|
      t.integer :marketing_email_id
      t.string :email_address

      t.timestamps
    end
  end
end
