# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :fulfillment_item do
    fulfillable_type "MyString"
    fulfillable_id 1
    fulfillment_method_id 1
    price_schedule "MyText"
    price_per_unit "9.99"
    weight_per_unit "9.99"
    taxable false
    description "MyText"
  end
end
