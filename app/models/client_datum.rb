# == Schema Information
#
# Table name: client_data
#
#  id                   :integer          not null, primary key
#  unique_key           :string(255)
#  client_data_type     :string(255)
#  client_data_sub_type :string(255)
#  status               :string(255)
#  expired              :boolean          default(FALSE)
#  data_values          :hstore
#  created_at           :datetime
#  updated_at           :datetime
#  token                :string(255)
#

class ClientDatum < ActiveRecord::Base
  include Tokenable

  validates :unique_key, uniqueness: true
  store_accessor :data_values
end
