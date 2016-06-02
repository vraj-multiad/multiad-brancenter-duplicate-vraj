json.array!(@shared_page_items) do |shared_page_item|
  json.extract! shared_page_item, :shared_page_id, :shareable_id, :shareable_type
  json.url shared_page_item_url(shared_page_item, format: :json)
end