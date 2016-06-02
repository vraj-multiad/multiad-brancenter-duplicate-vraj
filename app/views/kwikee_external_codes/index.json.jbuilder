json.array!(@kwikee_external_codes) do |kwikee_external_code|
  json.extract! kwikee_external_code, :kwikee_product_id, :kwikee_profile_id, :name, :value
  json.url kwikee_external_code_url(kwikee_external_code, format: :json)
end