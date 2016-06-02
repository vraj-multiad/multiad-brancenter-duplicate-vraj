# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dynamic_form_input_group do
    dynamic_form_id 1
    name "MyString"
    title "MyString"
    description "MyText"
    input_group_type "MyString"
    dynamic_form nil
  end
end
