json.array!(@fulfillment_methods) do |fulfillment_method|
  json.extract! fulfillment_method, :name, :title, :email_address
  json.url fulfillment_method_url(fulfillment_method, format: :json)
end