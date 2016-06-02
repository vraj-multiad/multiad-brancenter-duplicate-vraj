# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dynamic_form do
    name "MyString"
    title "MyString"
    description "MyText"
    recipient "MyString"
    expired false
    properties "MyText"
  end
end
