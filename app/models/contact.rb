# == Schema Information
#
# Table name: contacts
#
#  id                :integer          not null, primary key
#  contact_type_id   :integer          not null
#  first_name        :string(255)
#  last_name         :string(255)
#  title             :string(255)
#  company_name      :string(255)
#  address_1         :string(255)
#  address_2         :string(255)
#  city              :string(255)
#  state             :string(255)
#  zip_code          :string(255)
#  country           :string(255)
#  alt_address       :text
#  phone_number      :string(255)
#  fax_number        :string(255)
#  mobile_number     :string(255)
#  website           :string(255)
#  email_address     :string(255)
#  custom_contact_id :string(255)
#  facebook_id       :string(255)
#  twitter_id        :string(255)
#  comments          :text
#  map_link          :string(255)
#  shared_flag       :boolean          default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#  user_id           :integer
#  display_name      :string(255)
#

class Contact < ActiveRecord::Base
  belongs_to :contact_type
  belongs_to :user

  default_scope { order(display_name: :asc, first_name: :asc, last_name: :asc, company_name: :asc) }

  def one_line
    display_name.to_s + ': ' + first_name.to_s + ' ' + last_name.to_s + ' ' + company_name.to_s + ' ' + address_1.to_s + ' ' + address_2.to_s + ' ' + city.to_s + ', ' + state.to_s + ' ' + zip_code.to_s + ' ' + phone_number.to_s + ' ' + email_address.to_s
  end
end
