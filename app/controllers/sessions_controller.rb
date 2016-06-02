class SessionsController < ApplicationController
  before_action :already_logged_in?, only: [:new]
  skip_before_filter :verify_authenticity_token, only: [:saml_authenticate]
  # before_action :logged_in?

  def test
    @error_message = t('errors_saml_unauthorized').html_safe
    error
  end

  def new
    @selected_language = current_language
    @selected_language_title = 'English'

    @selected_language = params[:selected_language] if params[:selected_language].present?
    language = Language.where(name: @selected_language)
    if language.length > 0
      language.each do |lang|
        @selected_language_title = lang.title if @selected_language == lang.name
      end
      @selected_language_title = language[0].title
    end
    @languages = Language.all
  end

  def create
    user = User.active.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      if user.activated
        session[:user_id] = user.id
        redirect_to root_url
      else
        logger.debug('user.token: >' + user.token + '<')
        redirect_to login_url, notice: t('__alert_account_not_activated__')
      end
    else
      logger.debug 'Invalid username/password combination'
      redirect_to login_url, notice: t('__alert_invalid_combination__')
    end
  end

  def destroy
    user = current_user
    session[:user_id] = nil
    reset_session
    if params[:timeout].present?
      @error_message = t('__session_timeout__')
      return error if @error_message.present?
    end
    return redirect_to ENV['OMNIAUTH_SAML_IDP_SSO_TARGET_URL'] if ENV['OMNIAUTH_SAML_IDP_SSO_TARGET_URL'].present? && (!user || user.sso_flag)
    redirect_to login_path, notice: t('__alert_logged_out__')
  end

  def saml_authenticate
    # binding.pry
    logger.info 'saml_authenticate: omniauth.auth'
    logger.info env['omniauth.auth'].inspect
    redirect_to(ENV['OMNIAUTH_SAML_IDP_SSO_TARGET_URL'] || root_url) unless env['omniauth.auth'].present? && env['omniauth.auth']['uid'].present?
    user = nil
    if OMNIAUTH_SAML_PROVISION_USER_ROUTINE.present?
      user = send(OMNIAUTH_SAML_PROVISION_USER_ROUTINE)
    else
      username = env['omniauth.auth']['uid']
      user = User.where(username: username).activated.take
    end
    if user.present?
      session[:user_id] = user.id
    else
      ### redirect to idP login?
      @error_message = t('errors_saml_unauthorized').html_safe
      return error
    end
    redirect_to root_url # This method shows an error message
  end

  def error
    # looks for @error_message intended to be determined from translations ie: t('errors_saml_unauthorized').html_safe
    render 'error', layout: 'header_only'
  end
  # Custom routines for auth would go here.
  #
  #
  #
  #
  #
end
