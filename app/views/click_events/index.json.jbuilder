json.array!(@click_events) do |click_event|
  json.extract! click_event, :clickable_type, :clickable_id, :click_event_type, :event_name, :event_details
  json.url click_event_url(click_event, format: :json)
end