json.array!(@keyword_types) do |keyword_type|
  json.extract! keyword_type, :name, :title
  json.url keyword_type_url(keyword_type, format: :json)
end