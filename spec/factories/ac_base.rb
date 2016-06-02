# == Schema Information
#
# Table name: ac_bases
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  expired    :boolean          default(FALSE)
#  status     :string(255)      default("inprocess")
#

FactoryGirl.define do
  factory :ac_base do |f|
    f.name 'test'
    f.title 'test title'
    f.created_at DateTime.new(2001, 2, 3)
    f.updated_at DateTime.new(2001, 2, 4)
    f.expired false
    f.status 'inprocess'
  end
end
