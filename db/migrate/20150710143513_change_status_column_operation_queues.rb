class ChangeStatusColumnOperationQueues < ActiveRecord::Migration
  def change
    change_column :operation_queues, :status, :string, default: ''
  end
end
