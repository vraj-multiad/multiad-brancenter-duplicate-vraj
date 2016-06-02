# == Schema Information
#
# Table name: kwikee_external_codes
#
#  id                :integer          not null, primary key
#  kwikee_product_id :integer
#  kwikee_profile_id :integer
#  name              :string(255)
#  value             :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class KwikeeExternalCode < ActiveRecord::Base
  belongs_to :kwikee_product

  default_scope { order(kwikee_product_id: :asc, name: :asc) }
end
