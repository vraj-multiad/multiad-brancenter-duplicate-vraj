# == Schema Information
#
# Table name: dynamic_form_inputs
#
#  id                          :integer          not null, primary key
#  dynamic_form_input_group_id :integer
#  name                        :string(255)
#  title                       :string(255)
#  description                 :text
#  input_type                  :string(255)
#  input_choices               :text
#  required                    :boolean          default(FALSE)
#  created_at                  :datetime
#  updated_at                  :datetime
#  html_class                  :string(255)
#  dl_image_id                 :integer
#  min_date                    :string(255)
#  max_date                    :string(255)
#

class DynamicFormInput < ActiveRecord::Base
  include ApplicationHelper
  belongs_to :dl_image
  belongs_to :dynamic_form_input_group

  serialize :input_choices
  default_scope { order(name: :asc) }

  INPUT_TYPES = %w(text_field text_area check_box select attachment dl_image)
  HTML_CLASSES = %w(calendar heading)

  def attachment?
    input_type == 'attachment'
  end

  def parsed_input_choices
    # choices = [[I18n.translate('__select__'), '']]
    return sub_inputs if input_type == 'dl_image'
    return profile_state_select if input_choices == 'profile_state_select'
    choices = [['', '']]
    input_choices.split(/\r?\n/).each do |line|
      if line.match(/^.*:.*$/)
        # hash format
        choices << line.split(/:/)
      else
        choices << [line, line]
      end
    end
    choices
  end

  def sub_inputs
    sub_inputs = []
    input_choices.split(/\r?\n/).each do |line|
      input_type, name = line.split(/:/)
      sub_inputs << { 'input_type' => input_type, 'name' => name }
    end
    sub_inputs
  end
end
