class AddSubmittedAtAndCompletedAtToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :Order, :string
    add_column :orders, :submitted_at, :datetime
    add_column :orders, :completed_at, :datetime
  end
end
