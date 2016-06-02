# == Schema Information
#
# Table name: user_keywords
#
#  id                 :integer          not null, primary key
#  term               :text             not null
#  categorizable_id   :integer
#  categorizable_type :string(255)
#  user_id            :integer
#  user_keyword_type  :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  title              :string(255)
#

class UserKeyword < ActiveRecord::Base
  belongs_to :user
  scope :category, -> { where user_keyword_type: 'category' }
  scope :system, -> { where user_keyword_type: 'system' }
  scope :keyword, -> { where user_keyword_type: %w(keyword system) }

  references :categorizable, polymorphic: true
end
