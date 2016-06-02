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

FactoryGirl.define do
  factory :dl_cart_item do |f|
    f.id 1
    f.dl_cart_id 1
    f.downloadable_id 1
    f.downloadable_type 'video'
    f.created_at DateTime.new(2001, 2, 3)
    f.updated_at DateTime.new(2001, 2, 4)
  end
end
