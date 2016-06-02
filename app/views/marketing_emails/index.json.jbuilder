json.array!(@marketing_emails) do |marketing_email|
  json.extract! marketing_email, :ac_export_id, :user_id, :ac_creator_template_id, :ac_session_history_id
  json.url marketing_email_url(marketing_email, format: :json)
end