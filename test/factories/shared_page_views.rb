# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shared_page_view do
    shared_page_id 1
    token "MyString"
    reference "MyText"
  end
end
