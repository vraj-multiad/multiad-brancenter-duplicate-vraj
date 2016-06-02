json.array!(@ac_exports) do |ac_export|
  json.extract! ac_export, :ac_session_history_id, :email_address, :format, :location
  json.url ac_export_url(ac_export, format: :json)
end