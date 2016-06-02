json.array!(@keyword_terms) do |keyword_term|
  json.extract! keyword_term, :language_id, :term, :parent_term_id, :keyword_type
  json.url keyword_term_url(keyword_term, format: :json)
end
