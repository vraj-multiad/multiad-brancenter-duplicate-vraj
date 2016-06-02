require 'spec_helper'

describe UserMailer, type: :mailer do
  before(:all) do
    @test_user = FactoryGirl.create(:user, role: Role.first)
    @test_user.token = ''
    @test_user.user_type = 'user'
    @test_user.save
    ac_base = AcBase.create!
    ac_creator_template = ac_base.ac_creator_templates.create!
    ac_session = @test_user.ac_sessions.create!(ac_creator_template_id: ac_creator_template.id, ac_base_id: ac_base.id)
    ac_session_history = ac_session.ac_session_histories.create!
    ac_export = ac_session_history.ac_exports.create!(location: '/relative_url')
    fulfillment_method = FulfillmentMethod.create!(email_address:  @test_user.email_address, title: 'title')
    @order = fulfillment_method.orders.create!(user_id: @test_user.id)
    lang_data = Language.create!
    dynamic_from = lang_data.dynamic_forms.create!(email_text: @test_user.email_address)
    @dynamic_form_submission = dynamic_from.dynamic_form_submissions.create!
    @dynamic_form_submission.user = @test_user
  end
  context 'system_message_email' do
    let(:mail) do
      UserMailer.system_message_email("Hello #{@test_user.first_name}",
                                      "The test was successfully done #{@test_user.first_name}", @test_user.email_address)
    end
    it 'sends successfully' do
      expect(mail.subject).to match("Hello #{@test_user.first_name}")
      expect(mail.subject).to_not match('translation missing: ')
      expect(mail.body.encoded).to_not match('translation missing: ')
      expect(mail.to).to eql([@test_user.email_address])
      expect(mail.from).to eql([EMAIL_DEFAULT_FROM])
    end
  end
  context 'reset_password_email' do
    let(:mailEN) do
      UserMailer.reset_password_email(@test_user, :en)
    end
    let(:mailFR) do
      UserMailer.reset_password_email(@test_user, :fr)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailEN.to).to eql([@test_user.email_address])
      expect(mailEN.from).to eql([EMAIL_DEFAULT_FROM])
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
      expect(mailFR.to).to eql([@test_user.email_address])
      expect(mailFR.from).to eql([EMAIL_DEFAULT_FROM])
    end
  end
  context 'user_registration_notification_email' do
    let(:mailEN) do
      UserMailer.user_registration_notification_email(@test_user, :en)
    end
    let(:mailFR) do
      UserMailer.user_registration_notification_email(@test_user, :fr)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailEN.to).to eql([REGISTRATION_EMAIL])
      expect(mailEN.from).to eql([EMAIL_DEFAULT_FROM])
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
      expect(mailFR.to).to eql([REGISTRATION_EMAIL])
      expect(mailFR.from).to eql([EMAIL_DEFAULT_FROM])
    end
  end
  context 'user_registration_activation_email' do
    let(:mailEN) do
      UserMailer.user_registration_activation_email(@test_user, :en)
    end
    let(:mailFR) do
      UserMailer.user_registration_activation_email(@test_user, :fr)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailEN.to).to eql([@test_user.email_address])
      expect(mailEN.from).to eql([EMAIL_DEFAULT_FROM])
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
      expect(mailFR.to).to eql([@test_user.email_address])
      expect(mailFR.from).to eql([EMAIL_DEFAULT_FROM])
    end
  end
  context 'user_registration_approval_request_email' do
    let(:mailEN) do
      UserMailer.user_registration_approval_request_email(@test_user, :en)
    end
    let(:mailFR) do
      UserMailer.user_registration_approval_request_email(@test_user, :fr)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
    end
  end
  context 'user_registration_approval_notification_email' do
    let(:mailEN) do
      UserMailer.user_registration_approval_notification_email(@test_user, :en)
    end
    let(:mailFR) do
      UserMailer.user_registration_approval_notification_email(@test_user, :fr)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailEN.to).to eql([@test_user.email_address])
      expect(mailEN.from).to eql([EMAIL_DEFAULT_FROM])
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
      expect(mailFR.to).to eql([@test_user.email_address])
      expect(mailFR.from).to eql([EMAIL_DEFAULT_FROM])
    end
  end
  context 'user_activation_successful_email' do
    let(:mailEN) do
      UserMailer.user_activation_successful_email(@test_user, :en)
    end
    let(:mailFR) do
      UserMailer.user_activation_successful_email(@test_user, :fr)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailEN.to).to eql([@test_user.email_address])
      expect(mailEN.from).to eql([EMAIL_DEFAULT_FROM])
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
      expect(mailFR.to).to eql([@test_user.email_address])
      expect(mailFR.from).to eql([EMAIL_DEFAULT_FROM])
    end
  end
  context 'dl_cart_email' do
    let(:mailEN) do
      UserMailer.dl_cart_email(@test_user, 'pekin', :en)
    end
    let(:mailFR) do
      UserMailer.dl_cart_email(@test_user, 'pekin', :en)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailEN.to).to eql([@test_user.email_address])
      expect(mailEN.from).to eql([EMAIL_DEFAULT_FROM])
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
      expect(mailFR.to).to eql([@test_user.email_address])
      expect(mailFR.from).to eql([EMAIL_DEFAULT_FROM])
    end
  end
  context 'ac_export_email' do
    let(:mailEN) do
      UserMailer.ac_export_email(AcExport.first, :en)
    end
    let(:mailFR) do
      UserMailer.ac_export_email(AcExport.first, :fr)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailEN.to).to eql([@test_user.email_address])
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
      expect(mailFR.to).to eql([@test_user.email_address])
    end
  end
  context 'ac_export_order_fulfillment_email' do
    let(:mailEN) do
      UserMailer.ac_export_order_fulfillment_email(AcExport.first, :en)
    end
    let(:mailFR) do
      UserMailer.ac_export_order_fulfillment_email(AcExport.first, :fr)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
    end
  end
  context 'ac_export_order_confirmation_email' do
    let(:mailEN) do
      UserMailer.ac_export_order_confirmation_email(AcExport.first, :en)
    end
    let(:mailFR) do
      UserMailer.ac_export_order_confirmation_email(AcExport.first, :fr)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailEN.to).to eql([@test_user.email_address])
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
      expect(mailFR.to).to eql([@test_user.email_address])
    end
  end
  context 'ac_export_approval_notification_email_approver' do
    let(:mailEN) do
      UserMailer.ac_export_approval_notification_email_approver(AcExport.first, :en)
    end
    let(:mailFR) do
      UserMailer.ac_export_approval_notification_email_approver(AcExport.first, :fr)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
    end
  end
  context 'ac_export_approval_notification_email_user' do
    let(:mailEN) do
      UserMailer.ac_export_approval_notification_email_user(AcExport.first, 'shipped', 'comment', :en)
    end
    let(:mailFR) do
      UserMailer.ac_export_approval_notification_email_user(AcExport.first, 'shipped', 'comment', :en)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailEN.to).to eql([@test_user.email_address])
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
      expect(mailFR.to).to eql([@test_user.email_address])
    end
  end
  context 'social_media_post_email' do
    let(:mailEN) do
      UserMailer.social_media_post_email('link.com', @test_user.email_address, 'description', @test_user,
                                         :en, 'email subject')
    end
    let(:mailFR) do
      UserMailer.social_media_post_email('link.com', @test_user.email_address, 'description', @test_user,
                                         :fr, 'email subject')
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
    end
  end
  context 'cart_confirmation_email' do
    # order, current_language
    let(:mailEN) do
      UserMailer.cart_confirmation_email(@order, :en)
    end
    let(:mailFR) do
      UserMailer.cart_confirmation_email(@order, :fr)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
    end
  end
  context 'cart_confirmation_email' do
    let(:mailEN) do
      UserMailer.cart_confirmation_email(@order, :en)
    end
    let(:mailFR) do
      UserMailer.cart_confirmation_email(@order, :fr)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
    end
  end
  context 'cart_fulfillment_email' do
    let(:mailEN) do
      UserMailer.cart_fulfillment_email(@order, @order.fulfillment_method, :en)
    end
    let(:mailFR) do
      UserMailer.cart_fulfillment_email(@order, @order.fulfillment_method, :en)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
    end
  end
  context 'cart_status_update_email' do
    let(:mailEN) do
      UserMailer.cart_status_update_email(@order, 'subject', :en)
    end
    let(:mailFR) do
      UserMailer.cart_status_update_email(@order, 'subject', :en)
    end
    it 'sends successfully' do
      expect(mailEN.subject).to_not match('translation missing: ')
      expect(mailEN.body.encoded).to_not match('translation missing: ')
      expect(mailFR.subject).to_not match('translation missing: ')
      expect(mailFR.body.encoded).to_not match('translation missing: ')
    end
  end
  context 'dynamic_form_email' do
    # dynamic_form_submission, subject
    let(:mail) do
      UserMailer.dynamic_form_email(@dynamic_form_submission, 'subject')
    end
    it 'sends successfully' do
      expect(mail.subject).to_not match('translation missing: ')
      expect(mail.body.encoded).to_not match('translation missing: ')
    end
  end
  context 'publish_notification_email' do
    # results
    let(:mail) do
      assets = [{ 'owner_email_address' => @test_user.email_address, 'class_name' => 'AcCreatorTemplate', 'title' => 'title' }]
      result = { complete: assets }
      UserMailer.publish_notification_email(result, 'subject') # BUG!!!!!!!!
    end
    it 'sends successfully' do
      expect(mail.subject).to_not match('translation missing: ')
      expect(mail.body.encoded).to_not match('translation missing: ')
    end
  end
  context 'publish_soon_notification_email' do
    # results
    let(:mail) do
      result = [{ 'owner_email_address' => @test_user.email_address, 'class_name' => 'AcCreatorTemplate', 'title' => 'title' }]
      UserMailer.publish_soon_notification_email(result, 'subject') # BUG!!!!!!!!
    end
    it 'sends successfully' do
      expect(mail.subject).to_not match('translation missing: ')
      expect(mail.body.encoded).to_not match('translation missing: ')
    end
  end
  context 'unpublish_soon_notification_email' do
    # results
    let(:mail) do
      result = [{ 'owner_email_address' => @test_user.email_address, 'class_name' => 'AcCreatorTemplate', 'title' => 'title' }]
      UserMailer.unpublish_soon_notification_email(result, 'subject') # BUG!!!!!!!!
    end
    it 'sends successfully' do
      expect(mail.subject).to_not match('translation missing: ')
      expect(mail.body.encoded).to_not match('translation missing: ')
    end
  end
  context 'inline_email' do
    let(:mail) do
      recipient = @test_user.email_address
      UserMailer.inline_email('Email Subject', 'Email Body', recipient, DEFAULT_SYSTEM_EMAIL)
    end
    it 'sends successfully' do
      expect(mail.subject).to_not match('translation missing: ')
      expect(mail.body.encoded).to_not match('translation missing: ')
    end
  end
end
