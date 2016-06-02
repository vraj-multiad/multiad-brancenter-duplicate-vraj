# class ApplicationController < ActionController::Base
class ApplicationController < ActionController::Base
  before_filter :set_user_language
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_language, :set_current_language, :current_user, :real_user, :current_ac_session, :set_asset_group, :set_current_ac_session, :current_asset_group, :current_admin_keywordable_count, :current_shareable_count, :current_downloadable_count, :current_categorizable_count, :current_admin_keywords_count, :current_cart, :current_cart_items, :close_cart, :all_top_level_topics, :all_top_level_media_types, :logged_in?, :already_logged_in?, :superuser?, :become_user, :really_superuser?, :admin?, :contributor?
  # force_ssl

  private

  def set_session_timeout
    # rubocop:disable Style/SpaceAroundOperators
    @session_timeout_duration         = SESSION_TIMEOUT_DURATION         || 30 * 60 * 1000
    @session_timeout_warning_duration = SESSION_TIMEOUT_WARNING_DURATION ||  5 * 60 * 1000
  end

  def system_contacts_user
    User.find_by(username: 'SYSTEM CONTACTS')
  end

  def current_language
    current_language = I18n.default_locale
    current_language = session[:current_language] if session[:current_language].present?
    logger.debug current_language
    current_language
  end

  def set_current_language(current_language)
    session[:current_language] = current_language
  end

  def set_user_language
    current_language = session[:current_language] || nil
    I18n.locale = params[:selected_language] || current_language || I18n.default_locale
    set_current_language(I18n.locale)
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @current_user = User.find(session[:current_user_id]) if @current_user.present? && @current_user.superuser? && session[:current_user_id]
    @current_user
  end

  def real_user
    @real_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_ac_session
    session[:ac_session]
  end

  def set_current_ac_session(session_id)
    session[:ac_session] = session_id
  end

  def current_asset_group
    @asset_group = nil
    init_asset_group if session[:asset_group].nil?
    @asset_group = session[:asset_group]
  end

  def current_admin_keywordable_count
    count = 0
    current_asset_group.each do |asset_type, asset_items|
      next unless %w(DlImage DlImageGroup KwikeeProduct).include?(asset_type)
      asset_items.each do |token, _str|
        asset = LoadAsset.load_asset(type: asset_type, token: token)
        count += 1 if asset && (((asset_type == 'DlImage' &&  asset.user_id == current_user.id) || (asset_type == 'DlImageGroup')) && current_user.contributor?) || current_user.admin? || current_user.superuser?
      end
    end
    count
  end

  def current_shareable_count
    count = 0

    current_asset_group.each do |asset_type, asset_items|
      asset_items.each do |token, _str|
        asset = LoadAsset.load_asset(type: asset_type, token: token)
        count += 1 if asset && asset.shareable?
      end
    end
    count
  end

  def current_downloadable_count
    count = 0
    current_asset_group.each do |asset_type, asset_items|
      asset_items.each do |token, _str|
        asset = LoadAsset.load_asset(type: asset_type, token: token)
        count += 1 if asset && asset.downloadable?
      end
    end
    count
  end

  def current_categorizable_count
    count = 0
    current_asset_group.each do |asset_type, asset_items|
      asset_items.each do |token, _str|
        asset = LoadAsset.load_asset(type: asset_type, token: token)
        count += 1 if asset
      end
    end
    count
  end

  def current_admin_keywords_count
    count = 0
    current_asset_group.each do |asset_type, asset_items|
      asset_items.each do |token, _str|
        asset = LoadAsset.load_asset(type: asset_type, token: token)
        count += 1 if asset
      end
    end
    count
  end

  def init_asset_group
    session[:asset_group] = { 'AcCreatorTemplate' => {}, 'AcImage' => {}, 'DlImage' => {}, 'DlImageGroup' => {}, 'KwikeeAsset' => {}, 'KwikeeProduct' => {}, 'UserUploadedImage' => {} }
  end

  def set_asset_group(asset_group_type, token)
    @asset_group = current_asset_group
    logger.debug 'set_asset_group(1): ' + @asset_group.inspect
    logger.debug 'set_asset_group[asset_group_type]: ' + @asset_group[asset_group_type].inspect

    if @asset_group[asset_group_type][token]
      @asset_group[asset_group_type].delete(token)
    else
      @asset_group[asset_group_type][token] = 'active'
    end
    session[:asset_group] = @asset_group
    logger.debug 'set_asset_group(2): ' + @asset_group.inspect
    @asset_group
  end

  def current_cart
    # logger.debug 'current_cart id: ' + session[:cart_id].to_s
    if session[:cart_id]
      @current_cart ||= DlCart.find(session[:cart_id])
      # logger.debug 'current_cart_status: ' + @current_cart.status.to_s
      if @current_cart.status == 'downloaded'
        @current_cart = DlCart.create!(user_id: current_user.id)
        session[:cart_id] = @current_cart.id
      end
      # session[:cart_id] = nil if @current_cart.purchased_at
    end
    if session[:cart_id].nil?
      @current_cart = DlCart.create!(user_id: current_user.id)
      session[:cart_id] = @current_cart.id
    end
    @current_cart
  end

  def current_cart_items
    @current_cart_items = { 'KwikeeProduct' => {}, 'DlImage' => {}, 'UserUploadedImage' => {} }
    current_cart.dl_cart_items.each do |it|
      logger.debug 'current_cart_items: ' + it.inspect
      next unless it.downloadable_type == 'DlImage'
      @current_cart_items[it.downloadable_type][it.downloadable_id] = 'active'
    end
    @current_cart_items
  end

  def close_cart(cart_id)
    logger.debug 'close_cart cart_id: ' + cart_id.to_s
    logger.debug 'close_cart session[:cart_id]: ' + session[:cart_id].to_s
    return unless cart_id && session[:cart_id] == cart_id
    session[:cart_id] = nil
    current_cart
  end

  def logged_in?
    unless current_user
      return redirect_to ENV['OMNIAUTH_SAML_IDP_SSO_TARGET_URL'] if ENV['OMNIAUTH_SAML_IDP_SSO_TARGET_URL'].present?
      redirect_to login_url, notice: t('__please_login__')
    end
    set_session_timeout
  end

  def become_user(user_id)
    redirect_to login_url, notice: t('__please_login__') unless real_user
    session[:current_user_id] = user_id if real_user.superuser?
    redirect_to '/'
  end

  def really_superuser?
    set_session_timeout
    redirect_to login_url, notice: t('__please_login__') unless real_user
    redirect_to '/' unless real_user.superuser?
  end

  def superuser?
    set_session_timeout
    redirect_to login_url, notice: t('__please_login__') unless current_user
    redirect_to '/' unless current_user.superuser?
  end

  def admin?
    set_session_timeout
    redirect_to login_url, notice: t('__please_login__') unless current_user
    redirect_to '/' unless current_user.superuser? || current_user.admin?
  end

  def contributor?
    redirect_to login_url, notice: t('__please_login__') unless current_user
    set_session_timeout
    redirect_to '/' unless current_user.superuser? || current_user.admin? || current_user.contributor?
  end

  def already_logged_in?
    redirect_to '/' if current_user
  end

  def all_top_level_topics
    @top_level_topics = KeywordTerm.active.top_level_topics.order('term asc')
  end
  def all_top_level_media_types
    @top_level_media_types = KeywordTerm.active.top_level_media_types.order('term asc')
  end
end
