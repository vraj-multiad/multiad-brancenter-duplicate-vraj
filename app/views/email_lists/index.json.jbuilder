json.array!(@email_lists) do |email_list|
  json.extract! email_list, :user_id, :name, :title, :sheet, :token
  json.url email_list_url(email_list, format: :json)
end
