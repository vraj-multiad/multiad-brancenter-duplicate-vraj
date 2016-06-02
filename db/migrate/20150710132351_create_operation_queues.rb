class CreateOperationQueues < ActiveRecord::Migration
  def change
    create_table :operation_queues do |t|
      t.string :operable_type
      t.integer :operable_id
      t.string :queue_type
      t.string :operation_type
      t.string :operation
      t.string :status
      t.string :error_message
      t.string :path
      t.string :alt_path
      t.datetime :scheduled_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end
