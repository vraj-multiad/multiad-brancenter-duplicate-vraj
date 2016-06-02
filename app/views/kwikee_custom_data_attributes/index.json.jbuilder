json.array!(@kwikee_custom_data_attributes) do |kwikee_custom_data_attribute|
  json.extract! kwikee_custom_data_attribute, :kwikee_custom_data_id, :name, :value
  json.url kwikee_custom_data_attribute_url(kwikee_custom_data_attribute, format: :json)
end