# == Schema Information
#
# Table name: keyword_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  label      :string(255)
#

class KeywordType < ActiveRecord::Base
  default_scope { where "#{table_name}.name != ?", 'category' }
  scope :categories, -> { where "#{table_name}.name not in ('category','search')" }
end
