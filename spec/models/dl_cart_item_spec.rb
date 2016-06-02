# == Schema Information
#
# Table name: dl_cart_items
#
#  id                :integer          not null, primary key
#  dl_cart_id        :integer
#  downloadable_id   :integer
#  downloadable_type :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'

describe DlCartItem do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:dl_cart_item)).to be_valid
  end
  it 'invaild downloadable_id' do
    expect(FactoryGirl.build(:dl_cart_item, downloadable_id: nil)).to_not be_valid
  end
  it 'invaild downloadable_type' do
    expect(FactoryGirl.build(:dl_cart_item, downloadable_type: nil)).to_not be_valid
  end
  it 'invaild dl_cart_id' do
    expect(FactoryGirl.build(:dl_cart_item, dl_cart_id: nil)).to_not be_valid
  end
end
