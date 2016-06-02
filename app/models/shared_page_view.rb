# == Schema Information
#
# Table name: shared_page_views
#
#  id             :integer          not null, primary key
#  shared_page_id :integer
#  token          :string(255)
#  reference      :text
#  created_at     :datetime
#  updated_at     :datetime
#

class SharedPageView < ActiveRecord::Base
  include Tokenable
  belongs_to :shared_page
end
