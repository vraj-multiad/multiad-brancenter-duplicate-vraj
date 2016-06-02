json.array!(@shared_page_downloads) do |shared_page_download|
  json.extract! shared_page_download, :shared_page_id, :shareable_type, :shareable_id
  json.url shared_page_download_url(shared_page_download, format: :json)
end