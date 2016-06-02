class ChangeColumnLocationToRecipientListId < ActiveRecord::Migration
  def change
    add_column :marketing_emails, :email_list_id, :integer
  end
end
