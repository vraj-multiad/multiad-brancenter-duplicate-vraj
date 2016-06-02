json.array!(@responds_to_attributes) do |responds_to_attribute|
  json.extract! responds_to_attribute, :respondable_id, :respondable_type, :name, :value
  json.url responds_to_attribute_url(responds_to_attribute, format: :json)
end