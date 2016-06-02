class AddTokenToOperationQueue < ActiveRecord::Migration
  def change
    add_column :operation_queues, :token, :string
  end
end
