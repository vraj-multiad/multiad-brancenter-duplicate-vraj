json.array!(@operation_queues) do |operation_queue|
  json.extract! operation_queue, :operable_type, :operable_id, :queue_type, :operation_type, :operation, :status, :error_message, :path, :alt_path, :scheduled_at, :completed_at
  json.url operation_queue_url(operation_queue, format: :json)
end