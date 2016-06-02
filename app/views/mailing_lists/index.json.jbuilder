json.array!(@mailing_lists) do |mailing_list|
  json.extract! mailing_list, :user_id, :name, :title, :sheet, :status, :list_type, :token
  json.url mailing_list_url(mailing_list, format: :json)
end