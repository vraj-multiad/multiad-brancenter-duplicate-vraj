# == Schema Information
#
# Table name: failed_searches
#
#  id         :integer          not null, primary key
#  term       :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class FailedSearch < ActiveRecord::Base
  belongs_to :user
end
