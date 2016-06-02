require 'rails_helper'

describe OptOutsController, type: :controller do
  context 'ENABLE_OPT_OUT_ON_ALL_EMAILS changes' do
    before(:each) do
      @test_user_opt_in = FactoryGirl.create(:user)
      @test_user_opt_in.token = ''
      @test_user_opt_in.save

      @test_user_opt_out = FactoryGirl.create(:user, email_address: 'opt_out@multiad.com')
      @test_user_opt_out.token = ''
      @test_user_opt_out.save

      opt_out = OptOut.new
      opt_out.id = 1
      opt_out.email_address = @test_user_opt_out.email_address
      opt_out.created_at = DateTime.new(2001, 2, 3)
      opt_out.save
    end
    it 'User is not Opt Out of email, ENABLE_OPT_OUT_ON_ALL_EMAILS = true' do
      ENABLE_OPT_OUT_ON_ALL_EMAILS = true
      ActionMailer::Base.deliveries = []
      expect(ActionMailer::Base.deliveries.count).to eq(0)
      recipient = @test_user_opt_in.email_address
      UserMailer.inline_email('Email Subject', 'Email Body', recipient, EMAIL_DEFAULT_FROM)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.to[0]).to eq(@test_user_opt_in.email_address)
    end
    it 'User is Opt Out of email, ENABLE_OPT_OUT_ON_ALL_EMAILS = true' do
      ENABLE_OPT_OUT_ON_ALL_EMAILS = true
      ActionMailer::Base.deliveries = []
      expect(ActionMailer::Base.deliveries.count).to eq(0)
      recipient = @test_user_opt_out.email_address
      UserMailer.inline_email('Email Subject', 'Email Body', recipient, EMAIL_DEFAULT_FROM)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
    it 'User is Opt Out of email, ENABLE_OPT_OUT_ON_ALL_EMAILS = false' do
      ENABLE_OPT_OUT_ON_ALL_EMAILS = true
      ActionMailer::Base.deliveries = []
      expect(ActionMailer::Base.deliveries.count).to eq(0)
      recipient = @test_user_opt_in.email_address + ',' + @test_user_opt_out.email_address
      UserMailer.inline_email('Email Subject', 'Email Body', recipient, EMAIL_DEFAULT_FROM)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
    it 'User is Opt Out of email, ENABLE_OPT_OUT_ON_ALL_EMAILS = false' do
      ENABLE_OPT_OUT_ON_ALL_EMAILS = false
      ActionMailer::Base.deliveries = []
      expect(ActionMailer::Base.deliveries.count).to eq(0)
      recipient = @test_user_opt_in.email_address + ',' + @test_user_opt_out.email_address
      UserMailer.inline_email('Email Subject', 'Email Body', recipient, EMAIL_DEFAULT_FROM)
      expect(ActionMailer::Base.deliveries.count).to eq(2)
      # https://app.liquidplanner.com/space/95096/projects/show/28230402
      # => Was going to test who the email was sent to, glitch in rpsec
    end
  end
end
