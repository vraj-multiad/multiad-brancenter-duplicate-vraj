# == Schema Information
#
# Table name: kwikee_custom_data_attributes
#
#  id                     :integer          not null, primary key
#  kwikee_custom_datum_id :integer
#  name                   :string(255)
#  value                  :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#

class KwikeeCustomDataAttribute < ActiveRecord::Base
  belongs_to :kwikee_custom_datum

  default_scope { order(kwikee_custom_datum_id: :asc, name: :asc) }
end
