# == Schema Information
#
# Table name: click_events
#
#  id               :integer          not null, primary key
#  clickable_type   :string(255)
#  clickable_id     :integer
#  click_event_type :string(255)
#  event_name       :string(255)
#  event_details    :text
#  created_at       :datetime
#  updated_at       :datetime
#  user_id          :integer
#

class ClickEvent < ActiveRecord::Base
  belongs_to :user
  belongs_to :clickable, polymorphic: true

  default_scope { order(id: :asc) }
end
