require 'rails_helper'
# require './lib/tasks/required_records'

# => describe all actions of a user, using Rspec
describe UsersController, type: :controller do
  describe 'User' do
    context 'Creating new user' do
      # => before each test, fill the database with a user, and required records bandcenter must have
      # => such as language
      it 'Create a user sucessfully, Approved enable' do
        ActionMailer::Base.deliveries = []
        expect(ActionMailer::Base.deliveries.count).to eq(0)
        mail_count = ActionMailer::Base.deliveries.count # => get current email count
        ENABLE_USER_REGISTRATION = true
        ENABLE_USER_APPROVAL = true
        get :new
        get :create, user: { first_name: 'mike', last_name: 'tunner', address_1: '1233 north street', city: 'pekin',
                             state: 'IL', zip_code: '61554', phone_number: '555-555-5555', fax_number: '555-554-5643',
                             email_address: 'noreplay@wa.multiad.com', email_address_confirmation: 'noreplay@wa.multiad.com',
                             username: 'mike451777', password: 'password', password_confirmation: 'password',
                             country: 'USA' }, role_token: Role.default.first.token
        expect(ActionMailer::Base.deliveries.count).to eq(mail_count + 2) # => Check if email has been sent
        expect(ActionMailer::Base.deliveries.first.to[0]).to eq(APPROVER_EMAIL_USER).or eq(DEFAULT_SYSTEM_EMAIL)
        expect(ActionMailer::Base.deliveries.second.to[0]).to eq('noreplay@wa.multiad.com')
        ActionMailer::Base.deliveries = []
        expect(ActionMailer::Base.deliveries.count).to eq(0)
        mail_count = ActionMailer::Base.deliveries.count # => get current email count
        get :activate, activation_string: User.where(username: 'mike451777').take.token
        expect(ActionMailer::Base.deliveries.count).to eq(mail_count + 1) # => Check if email has been sent
        expect(ActionMailer::Base.deliveries.first.to[0]).to eq('noreplay@wa.multiad.com')
      end
      it 'Create a user sucessfully, Approved disabled' do
        ActionMailer::Base.deliveries = []
        expect(ActionMailer::Base.deliveries.count).to eq(0)
        mail_count = ActionMailer::Base.deliveries.count # => get current email count
        ENABLE_USER_REGISTRATION = true
        ENABLE_USER_APPROVAL = false
        get :new
        get :create, user: { first_name: 'mike', last_name: 'tunner', address_1: '1233 north street', city: 'pekin',
                             state: 'IL', zip_code: '61554', phone_number: '555-555-5555', fax_number: '555-554-5643',
                             email_address: 'noreplay@wa.multiad7.com', email_address_confirmation: 'noreplay@wa.multiad7.com',
                             username: 'mike451177', password: 'password', password_confirmation: 'password',
                             country: 'USA' }, role_token: Role.default.first.token
        expect(ActionMailer::Base.deliveries.count).to eq(mail_count + 2) # => Check if email has been sent
        expect(ActionMailer::Base.deliveries.first.to[0]).to eq('noreplay@wa.multiad7.com')
        expect(ActionMailer::Base.deliveries.second.to[0]).to eq(REGISTRATION_EMAIL)
        ActionMailer::Base.deliveries = []
        expect(ActionMailer::Base.deliveries.count).to eq(0)
        mail_count = ActionMailer::Base.deliveries.count # => get current email count
        get :activate, activation_string: User.where(username: 'mike451177').take.token
        expect(ActionMailer::Base.deliveries.count).to eq(mail_count + 1) # => Check if email has been sent
        expect(ActionMailer::Base.deliveries.first.to[0]).to eq('noreplay@wa.multiad7.com')
      end
    end
    context 'Not allowing new users' do
      # => before each test, fill the required records bandcenter must have
      # => such as language
      # => testing if what happens if create new user is turned off, and user tries to make new user
      it 'disabling the ENABLE_USER_REGISTRATION flag' do
        ENABLE_USER_REGISTRATION = false
        get :new
        expect(response).to redirect_to('/login')
      end
    end
    # => testing when the user forgot their password
    context 'Forgot Password' do
      # => before each test, fill the database with a user, and required records bandcenter must have
      # => such as language
      before(:each) do
        @test_user = FactoryGirl.create(:user)
        @test_user.token = ''
        @test_user.save
      end
      # => User does all the correct steps
      it 'user input correct email addess, and correct password' do
        mail_count = ActionMailer::Base.deliveries.count # => get current email count
        expect(@test_user.token).to eq('') # => Make sure user has no tokens
        expect(ActionMailer::Base.deliveries.count).to eq(mail_count) # => Check to make sure no email has been sent
        get :forgot_password, email_address: @test_user.email_address # => user clicks forget password, and inputs email addess
        expect(ActionMailer::Base.deliveries.count).to eq(mail_count + 1) # => Check if email has been sent
        @test_user.reload
        expect(@test_user.token).to_not eq('') # => User has token
        expect(response).to redirect_to('/login')
        get :reset_password, activation_string: @test_user.token # => reset password
        expect(response).to render_template('update_password')
        get :update_password, user: { password: 'pass', password_confirmation: 'pass' } # new password
        expect(response).to redirect_to('/login')
      end
      # => user inputs wrong email
      it 'user inputs incorrect email addess' do
        mail_count = ActionMailer::Base.deliveries.count # => get current email count
        expect(@test_user.token).to eq('') # => Make sure user has no tokens
        expect(ActionMailer::Base.deliveries.count).to eq(mail_count) # => Check to make sure no email has been sent
        get :forgot_password, email_address: 'wrongEmail@gmail.com' # => user inputs wrong email address
        expect(ActionMailer::Base.deliveries.count).to eq(mail_count) # => Check to make sure no email has been sent
        @test_user.reload
        expect(@test_user.token).to eq('') # => Make sure user has no tokens
        expect(response).to redirect_to('/login')
        get :reset_password, activation_string: 'badToken' # => try to reset password with wrong token
        expect(response).to_not render_template('update_password')
        expect(ActionMailer::Base.deliveries.count).to eq(mail_count) # => Check to make sure no email has been sent
      end
    end
  end
end
