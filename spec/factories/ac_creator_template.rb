# == Schema Information
#
# Table name: ac_creator_templates
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  title             :string(255)
#  bundle            :string(255)
#  preview           :string(255)
#  thumbnail         :string(255)
#  document_spec_xml :text
#  created_at        :datetime
#  updated_at        :datetime
#  ac_base_id        :integer
#  filename          :string(255)
#  folder            :string(255)
#  expired           :boolean          default(FALSE)
#  status            :string(255)      default("inprocess")
#  token             :string(255)
#  user_id           :integer
#  description       :text
#  publish_at        :datetime
#  unpublish_at      :datetime
#

FactoryGirl.define do
  factory :ac_creator_template do |f|
    f.name 'test'
    f.title 'test title'
    f.created_at DateTime.new(2001, 2, 3)
    f.updated_at DateTime.new(2001, 2, 4)
    f.expired false
    f.status 'inprocess'
  end
end
