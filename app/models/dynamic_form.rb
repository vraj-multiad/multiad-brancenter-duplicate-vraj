# == Schema Information
#
# Table name: dynamic_forms
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  title           :string(255)
#  description     :text
#  recipient       :string(255)
#  expired         :boolean          default(FALSE)
#  token           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  response_text   :text
#  recipient_field :string(255)
#  email_text      :text
#  published       :boolean          default(FALSE)
#  language_id     :integer
#

class DynamicForm < ActiveRecord::Base
  include Tokenable

  belongs_to :language
  has_many :dynamic_form_submissions
  has_many :dynamic_form_input_groups
  has_many :dynamic_form_inputs, through: :dynamic_form_input_groups
  default_scope { order(id: :asc) }
  scope :admin, -> { where(expired: false) }
  scope :active, -> { where(expired: false, published: true) }
  scope :inactive, -> { where('expired = ? or published = ?', true, false) }

  def all_dynamic_form_inputs
    DynamicFormInput.where(dynamic_form_input_group_id: dynamic_form_input_groups.pluck(:id)).pluck(:name, :name)
  end

  def required_inputs?
    DynamicFormInput.where(required: true, dynamic_form_input_group_id: dynamic_form_input_groups.pluck(:id)).count > 0
  end
end
