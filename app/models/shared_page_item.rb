# == Schema Information
#
# Table name: shared_page_items
#
#  id             :integer          not null, primary key
#  shared_page_id :integer
#  shareable_id   :integer
#  shareable_type :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class SharedPageItem < ActiveRecord::Base
  belongs_to :shared_page
  belongs_to :shareable, :polymorphic => true
  validates :shared_page_id, presence: true
  validates :shareable_id, presence: true
  validates :shareable_type, presence: true  
end
