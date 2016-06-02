json.array!(@shared_pages) do |shared_page|
  json.extract! shared_page, :user_id, :token, :expiration_date
  json.url shared_page_url(shared_page, format: :json)
end