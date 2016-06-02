FactoryGirl.define do
  factory :user do |f|
    f.sequence(:username) { |n| "username#{n}" }
    password 'password'
    password_confirmation 'password'
    f.sequence(:email_address) { |n| "email_address#{n}@example.com" }
    first_name 'first_name'
    last_name 'last_name'
    address_1 'address_1'
    city 'city'
    state 'IL'
    zip_code '11111'
    country 'US'
    phone_number '555-555-5555'
  end
end
