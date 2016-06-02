json.array!(@fulfillment_items) do |fulfillment_item|
  json.extract! fulfillment_item, :fulfillable_type, :fulfillable_id, :fulfillment_method_id, :price_schedule, :price_per_unit, :weight_per_unit, :taxable, :description
  json.url fulfillment_item_url(fulfillment_item, format: :json)
end