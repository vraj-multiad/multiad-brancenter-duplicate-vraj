json.array!(@user_keywords) do |user_keyword|
  json.extract! user_keyword, :term, :categorizable_id, :categorizable_type, :user_id, :user_keyword_type
  json.url user_keyword_url(user_keyword, format: :json)
end