# == Schema Information
#
# Table name: dl_carts
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  created_at          :datetime
#  updated_at          :datetime
#  email_address       :string(255)
#  status              :string(255)
#  location            :string(255)
#  cart_errors         :text
#  token               :string(255)
#  shared_page_token   :string(255)
#  asset_token         :string(255)
#  shared_page_view_id :integer
#

class DlCart < ActiveRecord::Base
  include Tokenable
  belongs_to :user
  has_many :user_downloads
  has_many :dl_cart_items
  has_many :operation_queues, as: :operable

  validates :email_address, format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }, on: :update, :allow_blank => true
end
