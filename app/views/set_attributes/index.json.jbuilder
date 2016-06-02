json.array!(@set_attributes) do |set_attribute|
  json.extract! set_attribute, :setable_id, :setable_type, :name, :value
  json.url set_attribute_url(set_attribute, format: :json)
end