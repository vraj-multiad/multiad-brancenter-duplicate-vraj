# == Schema Information
#
# Table name: kwikee_custom_data
#
#  id                :integer          not null, primary key
#  kwikee_product_id :integer
#  kwikee_profile_id :integer
#  name              :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class KwikeeCustomDatum < ActiveRecord::Base
  belongs_to :kwikee_product
  has_many :kwikee_custom_data_attributes, dependent: :delete_all

  default_scope { order(kwikee_product_id: :asc, name: :asc) }
end
