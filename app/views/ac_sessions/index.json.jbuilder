json.array!(@ac_sessions) do |ac_session|
  json.extract! ac_session, :user_id, :ac_creator_template, :ac_base_id
  json.url ac_session_url(ac_session, format: :json)
end