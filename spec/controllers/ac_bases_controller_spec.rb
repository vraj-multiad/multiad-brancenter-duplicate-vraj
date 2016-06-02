require 'spec_helper'

describe AcBasesController do
  before do
    @ac_base = AcBasesController.new
  end
  it 'Should return a new AcBase base object' do
    expect(@ac_base).to be_a AcBasesController
  end
end
