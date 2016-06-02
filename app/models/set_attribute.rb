# == Schema Information
#
# Table name: set_attributes
#
#  id           :integer          not null, primary key
#  setable_id   :integer
#  setable_type :string(255)
#  name         :string(255)
#  value        :text
#  created_at   :datetime
#  updated_at   :datetime
#

class SetAttribute < ActiveRecord::Base
  belongs_to :setable, polymorphic: true
end
