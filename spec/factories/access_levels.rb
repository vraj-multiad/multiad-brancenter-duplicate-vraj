# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :access_level do
    name "MyString"
    title "MyString"
    parent_access_level_id 1
  end
end
