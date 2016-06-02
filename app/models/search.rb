# == Schema Information
#
# Table name: searches
#
#  id         :integer          not null, primary key
#  term       :string(255)
#  user_id    :integer
#  keyword_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class Search < ActiveRecord::Base
  belongs_to :user
  belongs_to :keyword
end
