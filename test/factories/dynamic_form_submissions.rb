# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dynamic_form_submission do
    user nil
    dynamic_form nil
    token "MyString"
    properties "MyText"
    recipient "MyString"
  end
end
