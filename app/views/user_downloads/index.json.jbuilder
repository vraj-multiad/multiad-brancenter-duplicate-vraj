json.array!(@user_downloads) do |user_download|
  json.extract! user_download, :user_id, :dl_cart_id, :downloadable_id, :downloadable_type
  json.url user_download_url(user_download, format: :json)
end