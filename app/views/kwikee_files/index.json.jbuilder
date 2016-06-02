json.array!(@kwikee_files) do |kwikee_file|
  json.extract! kwikee_file, :kwikee_product_id, :kwikee_asset_id, :extension, :url
  json.url kwikee_file_url(kwikee_file, format: :json)
end