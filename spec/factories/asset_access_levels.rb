# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :asset_access_level do
    restrictable_type "MyString"
    restrictable_id 1
    access_level_id 1
  end
end
