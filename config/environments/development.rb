BrandCenter::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  # config.assets.precompile += %w( .svg .eot .woff .ttf )

  boolean_defaults = {
    'ENABLE_AC_EXPORT_EMAIL_BODY' => false,
    'ENABLE_AC_EXPORT_EMAIL_SUBJECT' => false,
    'ENABLE_AC_EXPORT_FROM_USER_EMAIL_ADDRESS' => false,
    'ENABLE_AC_ORDER_PANEL_DOWNLOAD_PDF' => false,
    'ENABLE_AC_ORDER_PANEL_DOWNLOAD_PNG' => false,
    'ENABLE_FULFILLMENT_CART_DOWNLOAD_PDF' => false,
    'ENABLE_FULFILLMENT_CART_DOWNLOAD_PNG' => false,
    'ENABLE_HELP' => false,
    'ENABLE_MY_DOCUMENTS' => true,
    'ENABLE_OPT_OUT_ON_ALL_EMAILS' => false,
    'ENABLE_PREVIEW_KEYWORD_DISPLAY' => true,
    'ENABLE_RESIZE_AC_IMAGE' => true,
    'ENABLE_RESIZE_USER_UPLOADED_IMAGE' => false,
    'ENABLE_SORT_NAME' => false,
    'ENABLE_SORT_TITLE' => true,
    'ENABLE_SORT_DATE' => true,
    'ENABLE_SORT_CUSTOM_1' => false,
    'ENABLE_SORT_CUSTOM_2' => false,
    'ENABLE_EMAIL_LIST_UPLOAD' => false,
    'ENABLE_MAILING_LIST_UPLOAD' => false,
    'ENABLE_INLINE_EMAIL_SUBJECT' => true,
    'ENABLE_MARKETING_EMAIL_SUBJECT' => true,
    'ENABLE_MARKETING_EMAIL_FROM' => true,
    'ENABLE_MARKETING_EMAIL_REPLY_TO' => true,
    'ENABLE_LOGO_UPLOAD' => true,
    'ENABLE_MY_LIBRARY_UPLOAD' => false,
    'ENABLE_ADVANCED_ORDER_DETAIL' => false,
    'ENABLE_SEARCH_FILTER' => true,
    'ENABLE_SEARCH_FILTER_AUTO_SEARCH' => true,
    'ENABLE_SEARCH_FILTER_MENU_ACCESS_LEVEL' => true,
    'ENABLE_SEARCH_FILTER_MENU_CATEGORY' => true,
    'ENABLE_SEARCH_FILTER_MENU_CATEGORY_ADCREATOR_SEARCH' => true,
    'ENABLE_SEARCH_FILTER_MENU_MEDIA_TYPE' => true,
    'ENABLE_SEARCH_FILTER_MENU_TOPIC' => true,
    'ENABLE_SOCIAL_MEDIA' => false,
    'ENABLE_SOCIAL_MEDIA_EMAIL_FROM_USER_EMAIL_ADDRESS' => false,
    'ENABLE_SOCIAL_MEDIA_EMAIL_SUBJECT' => true,
    'ENABLE_ADCREATOR_EXPORT_APPROVAL' => false,
    'ENABLE_ORDER_APPROVAL' => false,
    'ENABLE_ORDER_EMAIL_DOWNLOAD' => true,
    'ENABLE_USER_APPROVAL' => false,
    'ENABLE_CONTACT_CREATE' => false,
    'ENABLE_CONTACT_SHARE' => false,
    'ENABLE_CONTACTS' => false,
    'ENABLE_USER_REGISTRATION' => true,
    'ENABLE_USER_FORGOT_PASSWORD' => true,
    'ENABLE_FACEBOOK_ID' => false,
    'ENABLE_LINKEDIN_ID' => false,
    'ENABLE_TWITTER_ID' => false,
    'REQUIRE_FIRST_NAME' => true,
    'REQUIRE_LAST_NAME' => true,
    'REQUIRE_TITLE' => false,
    'REQUIRE_ADDRESS_1' => true,
    'REQUIRE_ADDRESS_2' => false,
    'REQUIRE_CITY' => true,
    'REQUIRE_STATE' => true,
    'REQUIRE_ZIP_CODE' => true,
    'REQUIRE_COUNTRY' => true,
    'REQUIRE_PHONE_NUMBER' => true,
    'REQUIRE_FAX_NUMBER' => false,
    'REQUIRE_MOBILE_NUMBER' => false,
    'REQUIRE_WEBSITE' => false,
    'REQUIRE_COMPANY_NAME' => false
  }
  boolean_defaults.each do |k, _v|
    case ENV[k]
    when 'true'
      boolean_defaults[k] = true
    when 'false'
      boolean_defaults[k] = false
    end
  end

  AC_BASE_URL = ENV['AC_BASE_URL']
  AC_DEBUG = ENV['AC_DEBUG'] || false
  ADMIN_URL = ENV['ADMIN_URL']
  APP_DOMAIN = ENV['APP_DOMAIN']
  APP_ID = ENV['APP_ID']
  APP_NAME_EMAIL = ENV['APP_NAME_EMAIL'] || 'BrandCenter'
  APP_NAME_LONG = ENV['APP_NAME_LONG']
  APP_NAME_PROPER = ENV['APP_NAME_PROPER']
  APP_NAME_SHORT = ENV['APP_NAME_SHORT']
  APPROVER_EMAIL_ADCREATOR = ENV['APPROVER_EMAIL_ADCREATOR']
  APPROVER_EMAIL_ORDER = ENV['APPROVER_EMAIL_ORDER']
  APPROVER_EMAIL_USER = ENV['APPROVER_EMAIL_USER']
  CART_URL = ENV['CART_URL']
  CONTACT_FIELDS = ENV['CONTACT_FIELDS']
  CS_BUILD_LOCATION = ENV['CS_BUILD_LOCATION']
  CS_BUILD_NAME = ENV['CS_BUILD_NAME']
  DEFAULT_COUNTRY = ENV['DEFAULT_COUNTRY'] || 'US'
  DEFAULT_MARKETING_EMAIL_FROM_NAME = ENV['DEFAULT_MARKETING_EMAIL_FROM_NAME']
  DEFAULT_MARKETING_EMAIL_FROM_ADDRESS = ENV['DEFAULT_MARKETING_EMAIL_FROM_ADDRESS']
  DEFAULT_PUBLISH_AT = (ENV['DEFAULT_PUBLISH_AT'] || '1').to_i # in days
  DEFAULT_PUBLISH_DURATION = (ENV['DEFAULT_PUBLISH_DURATION'] || '10').to_i # in years
  DEFAULT_SORT = ENV['DEFAULT_SORT'] || 'title_asc'
  DEFAULT_SYSTEM_EMAIL = ENV['DEFAULT_SYSTEM_EMAIL']
  DEFAULT_DYNAMIC_FORM_EMAIL = ENV['DEFAULT_DYNAMIC_FORM_EMAIL']
  DIRECT_REQUEST_URL = ENV['DIRECT_REQUEST_URL']
  DISPATCH_URL = 'http://cs-dispatch.herokuapp.com/register'
  EMAIL_DEFAULT_FROM = ENV['EMAIL_DEFAULT_FROM'] || 'noreply@multiadsolutions.com'
  ENABLE_AC_EXPORT_EMAIL_BODY = boolean_defaults['ENABLE_AC_EXPORT_EMAIL_BODY']
  ENABLE_AC_EXPORT_EMAIL_SUBJECT = boolean_defaults['ENABLE_AC_EXPORT_EMAIL_SUBJECT']
  ENABLE_AC_EXPORT_FROM_USER_EMAIL_ADDRESS = boolean_defaults['ENABLE_AC_EXPORT_FROM_USER_EMAIL_ADDRESS']
  ENABLE_AC_ORDER_PANEL_DOWNLOAD_PDF = boolean_defaults['ENABLE_AC_ORDER_PANEL_DOWNLOAD_PDF']
  ENABLE_AC_ORDER_PANEL_DOWNLOAD_PNG = boolean_defaults['ENABLE_AC_ORDER_PANEL_DOWNLOAD_PNG']
  ENABLE_FULFILLMENT_CART_DOWNLOAD_PDF = boolean_defaults['ENABLE_FULFILLMENT_CART_DOWNLOAD_PDF']
  ENABLE_FULFILLMENT_CART_DOWNLOAD_PNG = boolean_defaults['ENABLE_FULFILLMENT_CART_DOWNLOAD_PNG']
  ENABLE_HELP = boolean_defaults['ENABLE_HELP']
  ENABLE_MY_DOCUMENTS = boolean_defaults['ENABLE_MY_DOCUMENTS']
  ENABLE_OPT_OUT_ON_ALL_EMAILS = boolean_defaults['ENABLE_OPT_OUT_ON_ALL_EMAILS']
  ENABLE_PREVIEW_KEYWORD_DISPLAY = boolean_defaults['ENABLE_PREVIEW_KEYWORD_DISPLAY']
  ENABLE_RESIZE_AC_IMAGE = boolean_defaults['ENABLE_RESIZE_AC_IMAGE']
  ENABLE_RESIZE_USER_UPLOADED_IMAGE = boolean_defaults['ENABLE_RESIZE_USER_UPLOADED_IMAGE']
  ENABLE_SORT_NAME = boolean_defaults['ENABLE_SORT_NAME']
  ENABLE_SORT_TITLE = boolean_defaults['ENABLE_SORT_TITLE']
  ENABLE_SORT_DATE = boolean_defaults['ENABLE_SORT_DATE']
  ENABLE_SORT_CUSTOM_1 = boolean_defaults['ENABLE_SORT_CUSTOM_1']
  ENABLE_SORT_CUSTOM_2 = boolean_defaults['ENABLE_SORT_CUSTOM_2']
  ENABLE_EMAIL_LIST_UPLOAD = boolean_defaults['ENABLE_EMAIL_LIST_UPLOAD']
  ENABLE_MAILING_LIST_UPLOAD = boolean_defaults['ENABLE_MAILING_LIST_UPLOAD']
  ENABLE_INLINE_EMAIL_SUBJECT = boolean_defaults['ENABLE_INLINE_EMAIL_SUBJECT']
  ENABLE_MARKETING_EMAIL_SUBJECT = boolean_defaults['ENABLE_MARKETING_EMAIL_SUBJECT']
  ENABLE_MARKETING_EMAIL_FROM = boolean_defaults['ENABLE_MARKETING_EMAIL_FROM']
  ENABLE_MARKETING_EMAIL_REPLY_TO = boolean_defaults['ENABLE_MARKETING_EMAIL_REPLY_TO']
  ENABLE_LOGO_UPLOAD = boolean_defaults['ENABLE_LOGO_UPLOAD']
  ENABLE_MY_LIBRARY_UPLOAD = boolean_defaults['ENABLE_MY_LIBRARY_UPLOAD']
  ENABLE_ADVANCED_ORDER_DETAIL = boolean_defaults['ENABLE_ADVANCED_ORDER_DETAIL']
  ENABLE_SEARCH_FILTER = boolean_defaults['ENABLE_SEARCH_FILTER']
  ENABLE_SEARCH_FILTER_AUTO_SEARCH = boolean_defaults['ENABLE_SEARCH_FILTER_AUTO_SEARCH']
  ENABLE_SEARCH_FILTER_MENU_ACCESS_LEVEL = boolean_defaults['ENABLE_SEARCH_FILTER_MENU_ACCESS_LEVEL']
  ENABLE_SEARCH_FILTER_MENU_CATEGORY = boolean_defaults['ENABLE_SEARCH_FILTER_MENU_CATEGORY']
  ENABLE_SEARCH_FILTER_MENU_CATEGORY_ADCREATOR_SEARCH = boolean_defaults['ENABLE_SEARCH_FILTER_MENU_CATEGORY_ADCREATOR_SEARCH']
  ENABLE_SEARCH_FILTER_MENU_MEDIA_TYPE = boolean_defaults['ENABLE_SEARCH_FILTER_MENU_MEDIA_TYPE']
  ENABLE_SEARCH_FILTER_MENU_TOPIC = boolean_defaults['ENABLE_SEARCH_FILTER_MENU_TOPIC']
  ENABLE_SOCIAL_MEDIA = boolean_defaults['ENABLE_SOCIAL_MEDIA']
  ENABLE_SOCIAL_MEDIA_EMAIL_FROM_USER_EMAIL_ADDRESS = boolean_defaults['ENABLE_SOCIAL_MEDIA_EMAIL_FROM_USER_EMAIL_ADDRESS']
  ENABLE_SOCIAL_MEDIA_EMAIL_SUBJECT = boolean_defaults['ENABLE_SOCIAL_MEDIA_EMAIL_SUBJECT']
  ENABLE_ADCREATOR_EXPORT_APPROVAL = boolean_defaults['ENABLE_ADCREATOR_EXPORT_APPROVAL']
  ENABLE_ORDER_APPROVAL = boolean_defaults['ENABLE_ORDER_APPROVAL']
  ENABLE_ORDER_EMAIL_DOWNLOAD = boolean_defaults['ENABLE_ORDER_EMAIL_DOWNLOAD']
  ENABLE_USER_APPROVAL = boolean_defaults['ENABLE_USER_APPROVAL']
  ENABLE_CONTACT_CREATE = boolean_defaults['ENABLE_CONTACT_CREATE']
  ENABLE_CONTACT_SHARE = boolean_defaults['ENABLE_CONTACT_SHARE']
  ENABLE_CONTACTS = boolean_defaults['ENABLE_CONTACTS']
  ENABLE_USER_REGISTRATION = boolean_defaults['ENABLE_USER_REGISTRATION']
  ENABLE_USER_FORGOT_PASSWORD = boolean_defaults['ENABLE_USER_FORGOT_PASSWORD']
  ENABLE_FACEBOOK_ID = boolean_defaults['ENABLE_FACEBOOK_ID']
  ENABLE_LINKEDIN_ID = boolean_defaults['ENABLE_LINKEDIN_ID']
  ENABLE_TWITTER_ID = boolean_defaults['ENABLE_TWITTER_ID']
  KWIKEE_API_ACCESS_LEVELS = ENV['KWIKEE_API_ACCESS_LEVELS']
  KWIKEE_API_ENDPOINT = ENV['KWIKEE_API_ENDPOINT']
  KWIKEE_API_PASSWORD = ENV['KWIKEE_API_PASSWORD']
  KWIKEE_API_UPDATE_EMAIL = ENV['KWIKEE_API_UPDATE_EMAIL']
  KWIKEE_API_USERNAME = ENV['KWIKEE_API_USERNAME']
  KWIKEE_PRODUCT_CUSTOM_DATA_GROUPS = []
  KWIKEE_PRODUCT_CUSTOM_DATA_GROUPS = ENV['KWIKEE_PRODUCT_CUSTOM_DATA_GROUPS'].split(',') if ENV['KWIKEE_PRODUCT_CUSTOM_DATA_GROUPS'].present?
  MAX_RESULTS = (ENV['MAX_RESULTS'] || 200).to_i
  MAX_RESULTS_AC_SEARCH = (ENV['MAX_RESULTS_AC_SEARCH'] || 48).to_i
  MEDIA_EMAIL = ENV['MEDIA_EMAIL']
  MORE_AC_SEARCH_RESULTS_COUNT = (ENV['MORE_AC_SEARCH_RESULTS_COUNT'] || 12).to_i
  MORE_CATEGORY_RESULTS_COUNT = (ENV['MORE_CATEGORY_RESULTS_COUNT'] || 10).to_i
  MORE_SEARCH_RESULTS_COUNT = (ENV['MORE_SEARCH_RESULTS_COUNT'] || 25).to_i
  OMNIAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL = ENV['OMNIAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL']
  OMNIAUTH_SAML_IDP_SSO_TARGET_URL = ENV['OMNIAUTH_SAML_IDP_SSO_TARGET_URL']
  OMNIAUTH_SAML_IDP_CERT = ENV['OMNIAUTH_SAML_IDP_CERT']
  OMNIAUTH_SAML_IDP_CERT_FINGERPRINT = ENV['OMNIAUTH_SAML_IDP_CERT_FINGERPRINT']
  OMNIAUTH_SAML_IDP_CERT_FINGERPRINT_VALIDATOR = ENV['OMNIAUTH_SAML_IDP_CERT_FINGERPRINT_VALIDATOR']
  OMNIAUTH_SAML_ISSUER = ENV['OMNIAUTH_SAML_ISSUER']
  OMNIAUTH_SAML_NAME_IDENTIFIER_FORMAT = ENV['OMNIAUTH_SAML_NAME_IDENTIFIER_FORMAT']
  OMNIAUTH_SAML_PROVISION_USER_ROUTINE = ENV['OMNIAUTH_SAML_PROVISION_USER_ROUTINE']
  ORDER_EMAIL = ENV['ORDER_EMAIL']
  PICKUP_URL = ENV['PICKUP_URL']
  PUBLISH_NOTIFICATION_EMAIL = ENV['PUBLISH_NOTIFICATION_EMAIL']
  REGISTRATION_EMAIL = ENV['REGISTRATION_EMAIL']
  REQUIRE_FIRST_NAME = boolean_defaults['REQUIRE_FIRST_NAME']
  REQUIRE_LAST_NAME = boolean_defaults['REQUIRE_LAST_NAME']
  REQUIRE_TITLE = boolean_defaults['REQUIRE_TITLE']
  REQUIRE_ADDRESS_1 = boolean_defaults['REQUIRE_ADDRESS_1']
  REQUIRE_ADDRESS_2 = boolean_defaults['REQUIRE_ADDRESS_2']
  REQUIRE_CITY = boolean_defaults['REQUIRE_CITY']
  REQUIRE_STATE = boolean_defaults['REQUIRE_STATE']
  REQUIRE_ZIP_CODE = boolean_defaults['REQUIRE_ZIP_CODE']
  REQUIRE_COUNTRY = boolean_defaults['REQUIRE_COUNTRY']
  REQUIRE_PHONE_NUMBER = boolean_defaults['REQUIRE_PHONE_NUMBER']
  REQUIRE_FAX_NUMBER = boolean_defaults['REQUIRE_FAX_NUMBER']
  REQUIRE_MOBILE_NUMBER = boolean_defaults['REQUIRE_MOBILE_NUMBER']
  REQUIRE_WEBSITE = boolean_defaults['REQUIRE_WEBSITE']
  REQUIRE_COMPANY_NAME = boolean_defaults['REQUIRE_COMPANY_NAME']
  SECURE_BASE_URL = ENV['SECURE_BASE_URL']
  SAVED_AD_DURATION = (ENV['SAVED_AD_DURATION'] || 90).to_i
  SENDGRID_API_URL = ENV['SENDGRID_API_URL']
  SENDGRID_USERNAME = ENV['SENDGRID_USERNAME']
  SENDGRID_PASSWORD = ENV['SENDGRID_PASSWORD']
  SESSION_TIMEOUT_DURATION = (ENV['SESSION_TIMEOUT_DURATION'] || 60).to_i * 60 * 1000
  SESSION_TIMEOUT_WARNING_DURATION = (ENV['SESSION_TIMEOUT_WARNING_DURATION'] || 5).to_i * 60 * 1000
  SHARED_PAGE_DURATION = (ENV['SHARED_PAGE_DURATION'] || 90).to_i
  STATUS_URL = 'http://cs-dispatch.herokuapp.com/status'
  WORKSPACE_REFRESH = 5

  # Added per active admin install instructions
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  # config.force_ssl = (APP_DOMAIN =~ /^https:/).present?

  # These settings are for the sending out email for active admin and consequently the   devise mailer
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.smtp_settings =
    {
      user_name: ENV['SENDGRID_USERNAME'],
      password: ENV['SENDGRID_PASSWORD'],
      domain: ENV['SMTP_SETTINGS_DOMAIN'],
      address: ENV['SMTP_SETTINGS_ADDRESS'],
      port: ENV['SMTP_SETTINGS_PORT'],
      authentication: ENV['SMTP_SETTINGS_AUTHENTICATION']
    }

  BetterErrors::Middleware.allow_ip!('10.11.12.1') # if defined?(BetterErrors)
end
