json.array!(@kwikee_assets) do |kwikee_asset|
  json.extract! kwikee_asset, :kwikee_product_id, :asset_id, :promotion, :asset_type, :version, :view
  json.url kwikee_asset_url(kwikee_asset, format: :json)
end