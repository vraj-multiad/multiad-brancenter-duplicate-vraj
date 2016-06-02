json.array!(@marketing_email_recipients) do |marketing_email_recipient|
  json.extract! marketing_email_recipient, :marketing_email_id, :email_address
  json.url marketing_email_recipient_url(marketing_email_recipient, format: :json)
end