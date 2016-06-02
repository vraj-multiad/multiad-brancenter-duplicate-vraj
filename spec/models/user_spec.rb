# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  title                  :string(255)
#  address_1              :string(255)
#  address_2              :string(255)
#  city                   :string(255)
#  state                  :string(255)
#  zip_code               :string(255)
#  phone_number           :string(255)
#  fax_number             :string(255)
#  email_address          :string(255)
#  username               :string(255)
#  password_digest        :string(255)
#  last_login             :datetime
#  license_agreement_flag :boolean          default(FALSE)
#  update_profile_flag    :boolean          default(FALSE)
#  ship_first_name        :string(255)
#  ship_last_name         :string(255)
#  ship_address_1         :string(255)
#  ship_address_2         :string(255)
#  ship_city              :string(255)
#  ship_state             :string(255)
#  ship_zip_code          :string(255)
#  ship_phone_number      :string(255)
#  ship_fax_number        :string(255)
#  ship_email_address     :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  same_billing_shipping  :boolean          default(FALSE)
#  token                  :string(255)
#  activated              :boolean          default(FALSE)
#  user_type              :string(255)      default("user")
#  expired                :boolean          default(FALSE)
#  mobile_number          :string(255)
#  website                :string(255)
#  company_name           :string(255)
#  country                :string(255)
#  ship_country           :string(255)
#  role_id                :integer
#  external_account_id    :string(255)
#  cost_center            :string(255)
#  ship_company_name      :string(255)
#  sso_flag               :boolean          default(FALSE)
#  facebook_id            :string(255)
#  linkedin_id            :string(255)
#  twitter_id             :string(255)
#

require 'spec_helper'

describe User, type: :model do
  it 'has a valid user' do
    expect(FactoryGirl.create(:user)).to be_valid
  end
  # => Test all invalid combinations of making a user
  it 'has a invalid user' do
    # => 100% valid option hash for a user to enter
    valid_options = { username: 'username', password: 'password', password_confirmation: 'password', email_address: 'noreply@multiad.com',
                      first_name: 'first_name', last_name: 'last_name', address_1: 'address_1', address_2: 'address_2',
                      city: 'city', state: 'state', zip_code: 'zip_code',
                      country: 'US', phone_number: 'phone_number', fax_number: 'fax_number', mobile_number: 'mobile_number',
                      website: 'website', company_name: 'company_name' }

    # => 0% valid option hash for a user to enter
    invalid_option = { username: nil, password: nil, password_confirmation: nil, email_address: nil,
                       first_name: nil, last_name: nil, address_1: nil, address_2: nil, city: nil, state: nil, zip_code: nil,
                       country: nil, phone_number: nil, fax_number: nil, mobile_number: nil, website: nil, company_name: nil }
    # => What the user enters
    option = []
    option.push(valid_options)
    option.push(invalid_option)
    # => Array of items that are not required
    skip = []
    # => SECTION I BEGINS
    skip.push(0)
    skip.push(0)
    skip.push(0)
    skip.push(0)

    # => Check which items should be skipped for testing because they do not matter, 0 = Not skip, 1 = Skip
    # => MUST MATCH SECTION II
    if REQUIRE_FIRST_NAME == false
      invalid_option[:first_name] = valid_options[:first_name]
      skip.push(1)
    else
      skip.push(0)
    end
    if REQUIRE_LAST_NAME == false
      invalid_option[:last_name] = valid_options[:last_name]
      skip.push(1)
    else
      skip.push(0)
    end
    if REQUIRE_ADDRESS_1 == false
      invalid_option[:address_1] = valid_options[:address_1]
      skip.push(1)
    else
      skip.push(0)
    end
    if REQUIRE_ADDRESS_2 == false
      invalid_option[:address_2] = valid_options[:address_2]
      skip.push(1)
    else
      skip.push(0)
    end
    if REQUIRE_CITY == false
      invalid_option[:city] = valid_options[:city]
      skip.push(1)
    else
      skip.push(0)
    end
    if REQUIRE_STATE == false
      invalid_option[:state] = valid_options[:state]
      skip.push(1)
    else
      skip.push(0)
    end
    if REQUIRE_ZIP_CODE == false
      invalid_option[:zip_code] = valid_options[:zip_code]
      skip.push(1)
    else
      skip.push(0)
    end
    if REQUIRE_COUNTRY == false
      invalid_option[:country] = valid_options[:country]
      skip.push(1)
    else
      skip.push(0)
    end
    if REQUIRE_FAX_NUMBER == false
      invalid_option[:fax_number] = valid_options[:fax_number]
      skip.push(1)
    else
      skip.push(0)
    end
    if REQUIRE_MOBILE_NUMBER == false
      invalid_option[:mobile_number] = valid_options[:mobile_number]
      skip.push(1)
    else
      skip.push(0)
    end
    if REQUIRE_WEBSITE == false
      invalid_option[:website] = valid_options[:website]
      skip.push(1)
    else
      skip.push(0)
    end
    if REQUIRE_COMPANY_NAME == false
      invalid_option[:company_name] = valid_options[:company_name]
      skip.push(1)
    else
      skip.push(0)
    end
    if REQUIRE_PHONE_NUMBER == false
      invalid_option[:phone_number] = valid_options[:phone_number]
      skip.push(1)
    else
      skip.push(0)
    end
    # => End of SECTION I
    #
    # (0...option[0].size).each do |k| # For Debugging
    #   print skip[k]
    # end
    # puts "\n"
    (0...option[0].size).each do |i| # => Processing all invalid combination
      next unless skip[i] == 0 # => If initial invalid option does not matter skip test for that combination
      permutations = [] # => Current set of permutations of combination
      (0...option[0].size).each do |j| # => making combination
        if i != j
          permutations.push(0)
        else
          permutations.push(1)
        end
      end
      (0...option[0].size).each do |j| # => Testing of all combination
        # (0...option[0].size).each do |k| # For Debugging
        #   print permutations[k]
        # end
        # puts "\n"
        #
        # => START OF SECTION II
        expect(FactoryGirl.build(:user,
                                 username: option[permutations[0]][:username],
                                 password: option[permutations[1]][:password],
                                 password_confirmation: option[permutations[2]][:password_confirmation],
                                 email_address: option[permutations[3]][:email_address],
                                 first_name: option[permutations[4]][:first_name],
                                 last_name: option[permutations[5]][:last_name],
                                 address_1: option[permutations[6]][:address_1],
                                 address_2: option[permutations[7]][:address_2],
                                 city: option[permutations[8]][:city],
                                 state: option[permutations[9]][:state],
                                 zip_code: option[permutations[10]][:zip_code],
                                 country: option[permutations[11]][:country],
                                 fax_number: option[permutations[12]][:fax_number],
                                 mobile_number: option[permutations[13]][:mobile_number],
                                 website: option[permutations[14]][:website],
                                 company_name: option[permutations[15]][:company_name],
                                 phone_number: option[permutations[16]][:phone_number])).to_not be_valid
        permutations[j] = 1
        # => END OF SECTION II
      end
    end
  end
end
