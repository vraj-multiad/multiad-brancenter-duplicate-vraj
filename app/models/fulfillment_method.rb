# == Schema Information
#
# Table name: fulfillment_methods
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  title         :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  email_address :string(255)
#

# class FulfillmentMethod < ActiveRecord::Base
class FulfillmentMethod < ActiveRecord::Base
  has_many :orders
  has_many :fulfillment_items
  validates :email_address, presence: true,
                            format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create },
                            confirmation: true
end
