# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :keyword_index, :class => 'KeywordIndices' do
    indexable_type "MyString"
    indexable_id ""
    name "MyString"
    title "MyString"
    date "2015-10-01 16:02:57"
    custom "MyString"
  end
end
