# == Schema Information
#
# Table name: media_jobs
#
#  id                :integer          not null, primary key
#  job_id            :text
#  api               :text
#  mediajobable_type :text
#  mediajobable_id   :integer
#  output_type       :text
#  created_at        :datetime
#  updated_at        :datetime
#

class MediaJob < ActiveRecord::Base
  belongs_to :mediajobable, polymorphic: true

  scope :blitline, -> { where(api: 'blitline') }
end
