json.array!(@contact_types) do |contact_type|
  json.extract! contact_type, :name, :title
  json.url contact_type_url(contact_type, format: :json)
end