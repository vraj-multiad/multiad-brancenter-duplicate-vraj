# == Schema Information
#
# Table name: dl_cart_items
#
#  id                :integer          not null, primary key
#  dl_cart_id        :integer
#  downloadable_id   :integer
#  downloadable_type :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class DlCartItem < ActiveRecord::Base
  belongs_to :dl_cart
  belongs_to :downloadable, :polymorphic => true
  validates :dl_cart_id, presence: true
  validates :downloadable_id, presence: true
  validates :downloadable_type, presence: true
end
