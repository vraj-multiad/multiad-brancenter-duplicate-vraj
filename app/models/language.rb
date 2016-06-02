# == Schema Information
#
# Table name: languages
#
#  id    :integer          not null, primary key
#  name  :string(255)
#  title :string(255)
#

class Language < ActiveRecord::Base
  has_many :keyword_terms
  has_many :roles
  has_many :dynamic_forms
end
