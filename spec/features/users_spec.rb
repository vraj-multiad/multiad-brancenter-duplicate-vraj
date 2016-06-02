require 'spec_helper'

# => describe all actions of a user, using Capybara
describe User, type: :feature do
  context 'Making new user' do
    it 'A user is sucessful created' do
      ENABLE_USER_REGISTRATION = true
      num_of_user = User.count
      visit('/login')
      click_link('new-user')
      click_link('accept_terms')
      # => User inputs information
      fill_in('user_username', with: 'john4511777')
      fill_in('user_password', with: 'password')
      fill_in('user_password_confirmation', with: 'password')
      fill_in('user_first_name', with: 'John')
      fill_in('user_last_name', with: 'Walsher')
      fill_in('user_address_1', with: '1234 South 4 Street')
      fill_in('user_city', with: 'citytown')
      find('#user_state').find(:xpath, 'option[2]').select_option
      fill_in('user_zip_code', with: '61554')
      find('#user_country').find(:xpath, 'option[2]').select_option
      fill_in('user_phone_number', with: '555-555-5555')
      fill_in('user_email_address', with: 'noreply@multiad.com')
      fill_in('user_email_address_confirmation', with: 'noreply@multiad.com')
      # => User creates account
      click_button('Complete Registration')
      visit('/login')
      # => user actived account, from email
      user = User.find_by(username: 'john4511777')
      expect(User.count).to eq(num_of_user + 1)
      user.token = ''
      user.activated = true
      user.save
      # => User logs in
      fill_in('username', with: 'john4511777') # => user signs in
      fill_in('password', with: 'password')
      click_button('Sign In')
      click_link('here') if page.has_link?('here')
      expect(current_path).to eq('/home') # => user at home
    end
    it 'A user is un-sucessful make an account, incorrect email' do
      ENABLE_USER_REGISTRATION = true
      visit('/login')
      click_link('new-user')
      click_link('accept_terms')
      # => User inputs information
      fill_in('user_username', with: 'john4511777')
      fill_in('user_password', with: 'password')
      fill_in('user_password_confirmation', with: 'password')
      fill_in('user_first_name', with: 'John')
      fill_in('user_last_name', with: 'Walsher')
      fill_in('user_address_1', with: '1234 South 4 Street')
      fill_in('user_city', with: 'citytown')
      find('#user_state').find(:xpath, 'option[2]').select_option
      fill_in('user_zip_code', with: '61554')
      find('#user_country').find(:xpath, 'option[2]').select_option
      fill_in('user_phone_number', with: '555-555-5555')
      # => User creates account
      click_button('Complete Registration')
      expect(page).to have_content('Email address is invalid')
    end
    it 'Two users pick the same username' do
      ENABLE_USER_REGISTRATION = true
      # => User one make a user
      num_of_user = User.count
      visit('/login')
      click_link('new-user')
      click_link('accept_terms')
      # => User inputs information
      fill_in('user_username', with: 'john4511777')
      fill_in('user_password', with: 'password')
      fill_in('user_password_confirmation', with: 'password')
      fill_in('user_first_name', with: 'John')
      fill_in('user_last_name', with: 'Walsher')
      fill_in('user_address_1', with: '1234 South 4 Street')
      fill_in('user_city', with: 'citytown')
      find('#user_state').find(:xpath, 'option[2]').select_option
      fill_in('user_zip_code', with: '61554')
      find('#user_country').find(:xpath, 'option[2]').select_option
      fill_in('user_phone_number', with: '555-555-5555')
      fill_in('user_email_address', with: 'noreply@multiad.com')
      fill_in('user_email_address_confirmation', with: 'noreply@multiad.com')
      # => User creates account
      click_button('Complete Registration')
      visit('/login')
      # => user actived account, from email
      expect(User.count).to eq(num_of_user + 1)
      user = User.find_by(username: 'john4511777')
      user.token = ''
      user.activated = true
      user.save
      # => User two makes same user
      num_of_user = User.count
      visit('/login')
      click_link('new-user')
      click_link('accept_terms')
      # => User inputs information
      fill_in('user_username', with: 'john4511777')
      fill_in('user_password', with: 'password')
      fill_in('user_password_confirmation', with: 'password')
      fill_in('user_first_name', with: 'John')
      fill_in('user_last_name', with: 'Walsher')
      fill_in('user_address_1', with: '1234 South 4 Street')
      fill_in('user_city', with: 'citytown')
      find('#user_state').find(:xpath, 'option[2]').select_option
      fill_in('user_zip_code', with: '61554')
      find('#user_country').find(:xpath, 'option[2]').select_option
      fill_in('user_phone_number', with: '555-555-5555')
      fill_in('user_email_address', with: 'noreply@multiad.com')
      fill_in('user_email_address_confirmation', with: 'noreply@multiad.com')
      # => User creates account
      click_button('Complete Registration')
      expect(User.count).to eq(num_of_user)
    end
  end
  # => Testing all condtions of the user forgetting there password
  context 'Forgot Password' do
    # => before each test, fill the database with a user, and required records bandcenter must have
    # => such as language
    before(:each) do
      @test_user = FactoryGirl.create(:user)
      @test_user.token = ''
      @test_user.save
    end
    it 'user input correct email addess, and correct password, Is user new flag is false' do
      expect(@test_user.token).to eq('') # => user token should be blank
      visit('/login')
      click_link('Forgot password') # => user clicking forgot password
      fill_in('email_address', with: @test_user.email_address) # => User inputs correct email
      click_button('Submit')
      @test_user.token = 'dgIdjyjH7651S' # => Assign user token, simulates user checking email
      @test_user.save
      visit('/reset_password?activation_string=dgIdjyjH7651S') # => User click link in email
      fill_in('user_password', with: 'password1') # => user updates password
      fill_in('user_password_confirmation', with: 'password1')
      click_button('Reset Password') # => user resets password
      expect(page).to have_content(I18n.t('__alert_password_reset__')) # => User get alert password reseted
      fill_in('username', with: @test_user.username) # => user signs in
      fill_in('password', with: 'password1')
      @test_user.reload
      @test_user.update_profile_flag = false # => not a new user
      @test_user.save
      click_button('Sign In')
      click_link('here') if page.has_link?('here')
      expect(current_path).to eq('/home') # => user at home
    end
    it 'user input correct email addess, and correct password, Is user new flag flag is ture' do
      expect(@test_user.token).to eq('') # => user token should be blank
      visit('/login')
      click_link('Forgot password') # => user clicking forgot password
      fill_in('email_address', with: @test_user.email_address) # => User inputs correct email
      click_button('Submit')
      @test_user.token = 'dgIdjyjH7651S' # => Assign user token, simulates user checking email
      @test_user.save
      visit('/reset_password?activation_string=dgIdjyjH7651S') # => User click link in email
      fill_in('user_password', with: 'password1') # => user updates password
      fill_in('user_password_confirmation', with: 'password1')
      click_button('Reset Password')
      expect(page).to have_content(I18n.t('__alert_password_reset__')) # => User get alert password reseted
      fill_in('username', with: @test_user.username) # => user signs in
      fill_in('password', with: 'password1')
      @test_user.reload
      @test_user.update_profile_flag = true # => A new user
      @test_user.save
      click_button('Sign In')
      click_link('here') if page.has_link?('here')
      expect(current_path).to eq('/profile') # => user at profile
    end
    it 'user input mis-match password' do
      expect(@test_user.token).to eq('') # => user token should be blank
      visit('/login')
      click_link('Forgot password') # => user clicking forgot password
      fill_in('email_address', with: @test_user.email_address) # => User inputs correct email
      click_button('Submit')
      @test_user.token = 'dgIdjyjH7651S' # => Assign user token, simulates user checking email
      @test_user.save
      visit('/reset_password?activation_string=dgIdjyjH7651S') # => User get alert password reseted
      fill_in('user_password', with: 'password1') # => user updates password
      fill_in('user_password_confirmation', with: 'password12') # => user updates password
      click_button('Reset Password')
      expect(page).to have_content(I18n.t('__alert_password_mismatch__')) # => error
    end
    it 'user input invaild password' do
      expect(@test_user.token).to eq('') # => user token should be blank
      visit('/login')
      click_link('Forgot password') # => user clicking forgot password
      fill_in('email_address', with: @test_user.email_address) # => User inputs correct email
      click_button('Submit')
      @test_user.token = 'dgIdjyjH7651S' # => Assign user token, simulates user checking email
      @test_user.save
      visit('/reset_password?activation_string=dgIdjyjH7651S') # => User get alert password reseted
      fill_in('user_password', with: '') # => user updates password
      fill_in('user_password_confirmation', with: '')
      click_button('Reset Password')
      expect(page).to have_content(I18n.t('__alert_password_mismatch__'))
    end
  end
end
