Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], :scope => 'publish_actions,manage_pages'
  provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
  provider :youtube, ENV['YOUTUBE_CLIENT_ID'], ENV['YOUTUBE_CLIENT_SECRET'], authorize_params: { :access_type => 'offline', :approval_prompt => 'force' }
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

if ENV['OMNIAUTH_SAML_IDP_FINGERPRINT'].present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :saml,
      :assertion_consumer_service_url     => ENV['OMNIAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL'],
      :issuer                             => ENV['OMNIAUTH_SAML_ISSUER'],
      :idp_sso_target_url                 => ENV['OMNIAUTH_SAML_IDP_SSO_TARGET_URL'],
      :idp_cert_fingerprint               => ENV['OMNIAUTH_SAML_IDP_CERT_FINGERPRINT'],
      :name_identifier_format             => ENV['OMNIAUTH_SAML_NAME_IDENTIFIER_FORMAT']
  end
elsif ENV['OMNIAUTH_SAML_IDP_FINGERPRINT_VALIDATOR'].present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :saml,
      :assertion_consumer_service_url     => ENV['OMNIAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL'],
      :issuer                             => ENV['OMNIAUTH_SAML_ISSUER'],
      :idp_sso_target_url                 => ENV['OMNIAUTH_SAML_IDP_SSO_TARGET_URL'],
      :idp_cert_fingerprint_validator     => ENV['OMNIAUTH_SAML_IDP_CERT_FINGERPRINT_VALIDATOR'],
      :name_identifier_format             => ENV['OMNIAUTH_SAML_NAME_IDENTIFIER_FORMAT']
  end
elsif ENV['OMNIAUTH_SAML_IDP_CERT'].present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :saml,
      :assertion_consumer_service_url     => ENV['OMNIAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL'],
      :issuer                             => ENV['OMNIAUTH_SAML_ISSUER'],
      :idp_sso_target_url                 => ENV['OMNIAUTH_SAML_IDP_SSO_TARGET_URL'],
      :idp_cert                           => ENV['OMNIAUTH_SAML_IDP_CERT'],
      :name_identifier_format             => ENV['OMNIAUTH_SAML_NAME_IDENTIFIER_FORMAT']
  end
end
