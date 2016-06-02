json.array!(@roles) do |role|
  json.extract! role, :name, :title, :default_flag, :role_type
  json.url role_url(role, format: :json)
end