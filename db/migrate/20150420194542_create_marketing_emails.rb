class CreateMarketingEmails < ActiveRecord::Migration
  def change
    create_table :marketing_emails do |t|
      t.integer :ac_export_id
      t.integer :user_id
      t.integer :ac_creator_template_id
      t.integer :ac_session_history_id

      t.timestamps
    end
  end
end
