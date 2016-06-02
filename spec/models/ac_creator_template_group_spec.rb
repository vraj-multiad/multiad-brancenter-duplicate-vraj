# == Schema Information
#
# Table name: ac_creator_template_groups
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  title      :string(255)
#  token      :string(255)
#  spec       :text
#  created_at :datetime
#  updated_at :datetime
#


require 'spec_helper'

describe AcCreatorTemplateGroup do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:ac_creator_template_group)).to be_valid
  end
  before do
    @ac_creator_template_1a = FactoryGirl.create(:ac_creator_template, ac_creator_template_type: 'type1')
    @ac_creator_template_1b = FactoryGirl.create(:ac_creator_template, ac_creator_template_type: 'type1')
    @ac_creator_template_1c = FactoryGirl.create(:ac_creator_template, ac_creator_template_type: 'type1')
    @ac_creator_template_2a = FactoryGirl.create(:ac_creator_template, ac_creator_template_type: 'type2')
    @ac_creator_template_2b = FactoryGirl.create(:ac_creator_template, ac_creator_template_type: 'type2')
    @ac_creator_template_2c = FactoryGirl.create(:ac_creator_template, ac_creator_template_type: 'type2')
  end
  it 'supports sub_templates' do
    ac_creator_template_group_a = FactoryGirl.create(:ac_creator_template_group)
    ac_creator_template_group_b = FactoryGirl.create(:ac_creator_template_group)
    ac_creator_template_group_c = FactoryGirl.create(:ac_creator_template_group)

    ac_creator_template_group_a.ac_creator_templates << @ac_creator_template_1a
    ac_creator_template_group_a.ac_creator_templates << @ac_creator_template_2a
    expect(ac_creator_template_group_a.ac_creator_templates.length).to eq(2)

    ac_creator_template_group_b.ac_creator_templates << @ac_creator_template_1b
    ac_creator_template_group_b.ac_creator_templates << @ac_creator_template_2b
    expect(ac_creator_template_group_b.ac_creator_templates.length).to eq(2)

    ac_creator_template_group_c.ac_creator_templates << @ac_creator_template_1c
    ac_creator_template_group_c.ac_creator_templates << @ac_creator_template_2c
    expect(ac_creator_template_group_c.ac_creator_templates.length).to eq(2)
  end
end


