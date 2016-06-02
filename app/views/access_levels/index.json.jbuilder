json.array!(@access_levels) do |access_level|
  json.extract! access_level, :name, :title, :parent_access_level_id
  json.url access_level_url(access_level, format: :json)
end