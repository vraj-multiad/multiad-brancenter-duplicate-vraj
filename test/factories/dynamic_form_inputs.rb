# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dynamic_form_input do
    dynamic_form_input_group_id 1
    name "MyString"
    title "MyString"
    description "MyText"
    input_type "MyString"
    input_choices "MyText"
    required false
    dynamic_form_input_group nil
  end
end
