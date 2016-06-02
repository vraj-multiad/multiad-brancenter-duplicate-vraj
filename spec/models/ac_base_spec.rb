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
require 'spec_helper'

describe AcBase do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:ac_base)).to be_valid
  end
end
