# == Schema Information
#
# Table name: dynamic_form_input_groups
#
#  id               :integer          not null, primary key
#  dynamic_form_id  :integer
#  name             :string(255)
#  title            :string(255)
#  description      :text
#  input_group_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  html_class       :string(255)
#

class DynamicFormInputGroup < ActiveRecord::Base
  belongs_to :dynamic_form
  has_many :dynamic_form_inputs
  accepts_nested_attributes_for :dynamic_form_inputs, allow_destroy: true
  default_scope { order(dynamic_form_id: :asc, name: :asc) }

  def deep_copy
    dfig = self.dup
    dfig.name += ' copy'
    dfig.save
    dynamic_form_inputs.each do |dynamic_form_input|
      dfi = dynamic_form_input.dup
      dfi.dynamic_form_input_group_id = dfig.id
      dfi.save
    end
    dfig
  end
end
