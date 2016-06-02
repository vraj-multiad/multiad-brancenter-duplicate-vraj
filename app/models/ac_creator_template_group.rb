# == Schema Information
#
# Table name: ac_creator_template_groups
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  title      :string(255)
#  token      :string(255)
#  spec       :text
#  created_at :datetime
#  updated_at :datetime
#

class AcCreatorTemplateGroup < ActiveRecord::Base
  include Tokenable

  has_and_belongs_to_many :ac_creator_templates, join_table: :ac_creator_template_groups_ac_creator_templates
end
