require 'rails_helper'
# require './lib/tasks/supported_languages'

describe SessionsController, type: :feature, js: true do
  # context 'Testing Language' do
  #   before(:all) do
  #     create_supported_languages
  #     @test_user = FactoryGirl.create(:user)
  #     @test_user.token = ''
  #     @test_user.activated = true
  #     @test_user.user_type = 'superuser'
  #     @test_user.save
  #   end
  #   it 'Overall website languages' do
  #     supported_languages.each do |language|
  #       ENABLE_USER_REGISTRATION = true
  #       visit('/login?selected_language=' + language[:name].to_s)
  #       I18n.locale = language[:name]
  #       expect(page).to have_content(I18n.t('__please_login__'))
  #       expect(page).to have_content(I18n.t('__username__'))
  #       expect(page).to have_content(I18n.t('__password__'))
  #       expect(page).to have_content(I18n.t('__new_user__'))
  #       expect(page).to have_content(I18n.t('__forgot_password__'))
  #       expect(page).to have_selector(:link_or_button, I18n.t('__sign_in__'))
  #       visit('/register?selected_language=' + language[:name].to_s)
  #       expect(page).to have_content(I18n.t('__username__')) # Check to find 
  #       expect(page).to have_content(I18n.t('__password__'))
  #       expect(page).to have_content(I18n.t('__repeat_password__'))
  #       expect(page).to have_content(I18n.t('__first_name__'))
  #       expect(page).to have_content(I18n.t('__last_name__'))
  #       expect(page).to have_content(I18n.t('__title__'))
  #       expect(page).to have_content(I18n.t('__company_name__'))
  #       expect(page).to have_content(I18n.t('__address_1__'))
  #       expect(page).to have_content(I18n.t('__address_2__'))
  #       expect(page).to have_content(I18n.t('__city__'))
  #       expect(page).to have_content(I18n.t('__state__'))
  #       expect(page).to have_content(I18n.t('__zip_code__'))
  #       expect(page).to have_content(I18n.t('__country__'))
  #       expect(page).to have_content(I18n.t('__phone__'))
  #       expect(page).to have_content(I18n.t('__mobile__'))
  #       expect(page).to have_content(I18n.t('__website__'))
  #       expect(page).to have_content(I18n.t('__email_address__'))
  #       expect(page).to have_content(I18n.t('__repeat_email_address__'))
  #       expect(page).to have_selector(:link_or_button, I18n.t('__complete_registration__'))
  #       visit('/login?selected_language=' + language[:name].to_s)
  #       fill_in('username', with: @test_user.username) # => user signs in
  #       fill_in('password', with: 'password') # => user signs in
  #       click_button(I18n.t('__sign_in__'))
  #       click_link('here') if page.has_link?('here')
  #       expect(current_path).to eq('/home') # => user at home
  #       expect(page).to have_content(I18n.t('__home__').truncate(20).html_safe) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__administer__').truncate(20).html_safe) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__library__').truncate(20).html_safe) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__saved_ads__')) # => Not 100% guarantee
  #       click_link(I18n.t('__administer__').truncate(20).html_safe)
  #       expect(page).to have_content(I18n.t('__ac_images__')) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__edit_users_filters__')) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__contribute__')) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__logged_in__').truncate(20).html_safe) # => Not 100% guarantee
  #       expect(page).to have_content(@test_user.username.to_s) # => Not 100% guarantee
  #       click_link(@test_user.username.to_s)
  #       expect(page).to have_content(@test_user.first_name.to_s)
  #       expect(page).to have_content(@test_user.last_name.to_s)
  #       expect(page).to have_content(@test_user.email_address.to_s)
  #       # expect(page).to have_content(I18n.t('__change_user__').truncate(20).html_safe) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__view_profile__')) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__logout__')) # => Not 100% guarantee
  #       fill_in('keywords_', with: 'search')
  #       page.evaluate_script('runSearchForm();')
  #       expect(page).to have_content(I18n.t('__select_access_group__').truncate(20).html_safe) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__select_topic__')) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__global__').truncate(20).html_safe) # => Not 100% guarantee
  #       click_link(I18n.t('__global__').truncate(20).html_safe)
  #       expect(page).to have_content(I18n.t('__content_you_can_edit__').truncate(20).html_safe) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__content_you_can_download__')) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__content_you_uploaded__')) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__select_media_type__').truncate(20).html_safe) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__sort_options__').truncate(20).html_safe) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__no_available_content__')) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__sort_options__').truncate(20).html_safe) # => Not 100% guarantee
  #       click_link(I18n.t('__sort_options__').truncate(20).html_safe)
  #       expect(page).to have_content(I18n.t('__title_asc__').truncate(20).html_safe) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__title_desc__').truncate(20).html_safe) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__date_asc__').truncate(20).html_safe) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__date_desc__').truncate(20).html_safe) # => Not 100% guarantee
  #       visit('/my_library')
  #       expect(page).to have_content(I18n.t('__category_filter__')) # => Not 100% guarantee
  #       visit('/admin_ac_images')
  #       expect(page).to have_content(I18n.t('__upload_content__')) # => Not 100% guarantee
  #       visit('/admin')
  #       expect(page).to have_selector(:link_or_button, I18n.t('__add_delete_categories__')) # => Not 100% guarantee
  #       expect(page).to have_selector(:link_or_button, I18n.t('__edit_delete_users__')) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__select_language__')) # => Not 100% guarantee
  #       click_button(I18n.t('__edit_delete_users__'))
  #       expect(page).to have_content(I18n.t('__username__')) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__email_address__')) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__activated__'))
  #       expect(page).to have_content(I18n.t('__user_role__'))
  #       visit('/my_library')
  #       expect(page).to have_content(I18n.t('__category_filter__')) # => Not 100% guarantee
  #       visit('/my_documents')
  #       expect(page).to have_content(I18n.t('__select_access_group__').truncate(20).html_safe) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__select_topic__')) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__select_media_type__').truncate(20).html_safe)
  #       click_link(@test_user.username.to_s)
  #       click_link(I18n.t('__view_profile__'))
  #       expect(page).to have_content(I18n.t('__user_info__')) # => Not 100% guarantee
  #       expect(page).to have_content(I18n.t('__address__'))
  #       expect(page).to have_content(I18n.t('__phone_single__'))
  #       expect(page).to have_content(I18n.t('__mobile_single__'))
  #       expect(page).to have_content(I18n.t('__fax_single__'))
  #       expect(page).to have_content(I18n.t('__email_single__'))
  #       expect(page).to have_content(I18n.t('__system_settings__'))
  #       expect(page).to have_content(I18n.t('__change_password__'))
  #       expect(page).to have_content(I18n.t('__upload_logo__'))
  #       expect(page).to have_content(I18n.t('__uploaded_logos__'))
  #       visit('/logout?selected_language=' + language[:name].to_s)
  #       I18n.locale = language[:name]
  #       expect(page).to have_content(I18n.t('__alert_logged_out__'))
  #       #
  #       # => Will fail test, because of bug.
  #       # => The logout page is always English
  #       # => Liquid Planner ID: 28072435
  #       # => Liquid Planner Link: https://app.liquidplanner.com/space/95096/projects/show/28072435
  #       #
  #       #
  #       # expect(page).to have_content(I18n.t('__please_login__'))
  #       # expect(page).to have_content(I18n.t('__username__'))
  #       # expect(page).to have_content(I18n.t('__password__'))
  #       # expect(page).to have_content(I18n.t('__new_user__'))
  #       # expect(page).to have_content(I18n.t('__forgot_password__'))
  #       #
  #       #
  #       #
  #     end
  #   end
  # end
end
