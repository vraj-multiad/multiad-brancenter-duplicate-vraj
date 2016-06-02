json.array!(@dl_cart_items) do |dl_cart_item|
  json.extract! dl_cart_item, :dl_cart_id, :downloadable_id, :downloadable_type
  json.url dl_cart_item_url(dl_cart_item, format: :json)
end