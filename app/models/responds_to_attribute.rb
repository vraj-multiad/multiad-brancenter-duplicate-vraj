# == Schema Information
#
# Table name: responds_to_attributes
#
#  id               :integer          not null, primary key
#  respondable_id   :integer
#  respondable_type :string(255)
#  name             :string(255)
#  value            :text
#  created_at       :datetime
#  updated_at       :datetime
#

class RespondsToAttribute < ActiveRecord::Base
  belongs_to :respondable, polymorphic: true
end
