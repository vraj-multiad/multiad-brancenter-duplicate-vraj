json.array!(@kwikee_custom_data) do |kwikee_custom_datum|
  json.extract! kwikee_custom_datum, :kwikee_product_id, :kwikee_profile_id, :name
  json.url kwikee_custom_datum_url(kwikee_custom_datum, format: :json)
end