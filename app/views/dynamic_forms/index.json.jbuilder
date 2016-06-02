json.array!(@dynamic_forms) do |dynamic_form|
  json.extract! dynamic_form, :name, :title, :description, :recipient, :expired, :token
  json.url dynamic_form_url(dynamic_form, format: :json)
end