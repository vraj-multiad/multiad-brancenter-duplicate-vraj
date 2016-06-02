json.array!(@ac_session_histories) do |ac_session_history|
  json.extract! ac_session_history, :name, :expired, :previous_ac_document_id, :ac_document_id, :ac_session_id
  json.url ac_session_history_url(ac_session_history, format: :json)
end