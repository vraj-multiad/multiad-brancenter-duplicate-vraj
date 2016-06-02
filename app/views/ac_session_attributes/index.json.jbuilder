json.array!(@ac_session_attributes) do |ac_session_attribute|
  json.extract! ac_session_attribute, :ac_session_history_id, :name, :value, :ac_step_id, :attribute_type
  json.url ac_session_attribute_url(ac_session_attribute, format: :json)
end