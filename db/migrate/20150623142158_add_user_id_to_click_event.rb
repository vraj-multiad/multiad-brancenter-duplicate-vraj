class AddUserIdToClickEvent < ActiveRecord::Migration
  def change
    add_column :click_events, :user_id, :integer
  end
end
