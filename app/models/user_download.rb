# == Schema Information
#
# Table name: user_downloads
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  dl_cart_id        :integer
#  downloadable_id   :integer
#  downloadable_type :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class UserDownload < ActiveRecord::Base
  belongs_to :user
  belongs_to :downloadable, :polymorphic => true
  belongs_to :dl_cart
  validates :user_id, presence: true
  validates :downloadable_id, presence: true
  validates :downloadable_type, presence: true
end
