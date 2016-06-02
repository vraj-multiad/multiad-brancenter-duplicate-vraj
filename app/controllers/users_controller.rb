class UsersController < ApplicationController
  before_action :already_logged_in?, only: [:new]
  before_action :logged_in?, only: [:profile, :update, :change_password, :user_email_lists, :user_order_details, :user_orders, :user_marketing_emails]
  before_action :get_user_by_token, only: [:update_password]
  before_action :contributor?, only: [:admin_edit_assets]
  before_action :admin?, only: [:index, :show, :edit, :destroy, :admin, :admin_edit, :admin_save, :admin_reset_password, :admin_expire]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :change_password]
  before_action :admin_set_user, only: [:admin_save]
  before_action :really_superuser?, only: [:superuser, :superuser_become_user]
  # skip_before_action :verify_authenticity_token, :only => [:asset_group_add]

  def user_orders
    @orders = current_user.orders.history
    render partial: 'orders/user_orders'
  end

  def user_order_details
    render nothing: true unless params[:id].present?
    @order = current_user.orders.find(params[:id])
    render nothing: true unless @order.present?
    render partial: 'orders/user_order_details'
  end

  def user_mailing_lists
    @user = current_user
    # render partial: 'email_lists/user_email_lists', locals: { email_lists: @user.email_lists }
    render partial: 'mailing_lists/user_mailing_lists', locals: { mailing_lists: @user.mailing_lists }
  end

  def user_marketing_emails
    @marketing_emails = current_user.marketing_emails
    render partial: 'marketing_emails/sent_marketing_emails'
  end

  def user_marketing_email_stats
    @user = current_user
    @marketing_email = nil
    @marketing_email_stats = nil
    if params[:token].present?
      @marketing_email = @user.marketing_emails.where(token: params[:token]).take
      @marketing_email_stats = @marketing_email.sendgrid_get_email_stats
    end
    render partial: 'marketing_emails/marketing_email_stats'
  end

  def user_email_lists
    @user = current_user
    # render partial: 'email_lists/user_email_lists', locals: { email_lists: @user.email_lists }
    render partial: 'email_lists/user_email_lists', locals: { email_lists: @user.email_lists }
  end

  ##### admin_edit_assets
  def admin_edit_assets_update
    asset = LoadAsset.load_asset(type: params[:asset_type], token: params[:asset_token])
    old_terms = []
    new_terms = []
    if asset.has_attribute?(:title) && params[:title].present?
      old_terms << asset.title.downcase if asset.title.present?
      new_terms << params[:title].downcase
      asset.title = params[:title]
    end
    if asset.has_attribute?(:description)
      old_terms << asset.description.downcase if asset.description.present?
      new_terms << params[:description].downcase
      asset.description = params[:description]
    end

    asset.publish_at = params[:publish_at] if asset.has_attribute?(:publish_at)
    asset.unpublish_at = params[:unpublish_at] if asset.has_attribute?(:unpublish_at)

    asset.is_downloadable = params[:is_downloadable] if asset.has_attribute?(:is_downloadable)
    asset.is_shareable_via_email = params[:is_shareable_via_email] if asset.has_attribute?(:is_shareable_via_email)
    asset.is_shareable_via_social_media = params[:is_shareable_via_social_media] if asset.has_attribute?(:is_shareable_via_social_media)

    if asset.has_attribute?(:external_link_label) && asset.has_attribute?(:external_link) && asset.has_attribute?(:external_link_label)
      old_terms << asset.external_link_label.downcase if asset.external_link_label.present?
      if params[:external_link_label].present? && params[:external_link].present?
        new_terms << params[:external_link_label].downcase
        asset.external_link_label = params[:external_link_label]
        asset.external_link = params[:external_link]
      else
        asset.external_link_label = ''
        asset.external_link = ''
      end
    end

    asset.keywords.where(keyword_type: 'system', term: old_terms).destroy_all
    new_terms.each do |new_term|
      next unless new_term.present?
      next if asset.keywords.where(term: new_term, keyword_type: 'system').present?
      asset.keywords.create(term: new_term, keyword_type: 'system')
    end

    edit_asset_messages = 'Asset update failed'
    if asset.save!
      edit_asset_messages = 'Asset updated'
      asset.publish
    end

    render partial: 'admin_edit_asset_details', locals: { edit_asset: asset, edit_asset_messages: [edit_asset_messages], i: params[:asset_index], asset_count: params[:asset_count] }
  end
  ##### admin_edit_assets
  def admin_edit_assets
    assets = params[:asset]
    @edit_assets = []
    assets.each do |asset_type_and_token|
      asset_type, token = asset_type_and_token.split('|')
      @edit_assets << LoadAsset.load_asset(type: asset_type, token: token)
    end
    render partial: 'admin_edit_assets'
  end

  ##### superuser
  def superuser
    @users = User.active
    render 'superuser'
  end

  def superuser_become_user
    user = User.find_by(id: params[:id])
    if user.present?
      init_asset_group
      return become_user(user.id)
    end
    superuser
  end

  def admin
    @real_user = real_user
    @access_levels = @real_user.permissions

    @access_level = nil

    limit = 50.0
    @current_page = params[:user_results_page].to_i || 1
    @current_page = 1 if @current_page < 1
    offset = (@current_page - 1) * limit

    if params[:access_level].present? && @real_user.has_access?(params[:access_level])
      # specific access_level
      al = AccessLevel.find(params[:access_level])
      @access_level = al
      all_users = al.users.active.admin_and_below
    else
      if @access_levels.count > 0 && !@real_user.superuser?
        access_ids = @real_user.access_levels.pluck(:id)
        all_users = User.unscoped.includes(:access_levels).where(access_levels: { id: access_ids }).order("username asc").active.admin_and_below
      else
        all_users = User.active.admin_and_below
      end
    end
    @search = params[:user_search]
    if @search.present?
      search = @search.downcase
      field_exceptions = %w(password_digest token)
      user_search_fields = []
      User.columns.each do |c|
        next if field_exceptions.include?(c.name.to_s)
        next unless %w(text string).include?(c.type.to_s)
        user_search_fields << c.name.to_s
      end
      user_search_fields.map! do |field|
        "lower(\"users\".\"#{field}\") LIKE ?"
      end

      all_users = all_users.where(user_search_fields.join(' OR '), *(["%#{search}%"] * user_search_fields.size))

    end
    @users = all_users.limit(limit).offset(offset)
    @num_pages = (all_users.count / limit).ceil
    render partial: 'admin'
  end

  def admin_edit
    id = params[:admin_user_edit_id]
    @access_levels = AccessLevel.all
    # if real_user.superuser?
    # else
    #   @access_levels = real_user.access_levels
    # end
    @real_user = real_user
    @user = User.find(id)
    render partial: 'admin_edit'
  end

  def admin_expire
    id = params[:admin_user_expire_id]
    @user = User.find(id)
    @user.username = @user.username + '=expired ' + Time.now.to_s
    @user.email_address = @user.email_address + '=expired' + Time.now.to_s
    @user.expired = true
    @user.save(validate: false)
    admin
  end

  def admin_save
    update_params = admin_edit_user_params
    tokens_to_ids = AccessLevel.where(token: update_params[:access_level_ids])
    tokens_to_ids = tokens_to_ids.reject { |x| !real_user.permissions.include?(x) }
    # Add back current permissions not adminable by real_user
    other_access_levels = @user.permissions.pluck(:id) - real_user.permissions.without_reserved.pluck(:id)
    update_params[:access_level_ids] = tokens_to_ids.map(&:id) + other_access_levels
    @user.update(update_params)
    admin
  end

  def admin_reset_password
    id = params[:admin_user_reset_password_id]
    @user = User.find(id)

    if @user
      @user.token = ''
      @user.token = @user.generate_token
      @user.save(validate: false)
      UserMailer.reset_password_email(@user, current_language).deliver
    end
    admin
  end

  def asset_group_init
    asset_group = init_asset_group
    logger.debug asset_group
    render nothing: true
  end

  def asset_group_add
    asset_group_type = params[:asset_group_type]
    token = params[:token]
    @asset_group = set_asset_group(asset_group_type, token)
    logger.debug 'asset_group_add: ' + @asset_group.inspect
    render nothing: true
  end

  def asset_group_display
    @asset_group = current_asset_group
    logger.debug '@asset_group.inspect'
    logger.debug @asset_group.inspect
    render partial: 'asset_group_display'
  end

  def attachments
    @user = current_user
    return render nothing: true if true
    render partial: 'attachments'
  end

  def logos
    @user = current_user
    render partial: 'logos'
  end

  def change_password
    if @user.authenticate(params[:old_password]) && @user.update(update_password_params)
      @user.save!
      redirect_to profile_url, notice: t('__alert_password_updated__')
    else
      redirect_to profile_url, notice: t('__alert_password_mismatch__')
    end
  end

  def update_password
    if @user
      logger.debug('@user.token: ' + @user.token)
      if params[:user][:password].present? && params[:user][:password] == params[:user][:password_confirmation]
        @user.token = nil
        @user.activated = true
        @user.password = params[:user][:password]
        @user.update_profile_flag = true unless @user.valid?
        @user.save(validate: false)
        redirect_to login_url, notice: t('__alert_password_reset__')
      else
        redirect_to login_url, notice: t('__alert_password_mismatch__')
      end
    else
      redirect_to login_url, notice: t('__alert_invalid_activation__')
    end
  end

  def reset_password
    token = params[:activation_string]
    @user = User.find_by(token: token)
    if @user
      logger.debug('@user.token: ' + @user.token)
      @user.activated = true
      @user.save(validate: false)
      render 'update_password'
    else
      redirect_to login_url, notice: ''
    end
  end

  def forgot_password
    redirect_to login_url unless ENABLE_USER_FORGOT_PASSWORD
    email_address = params[:email_address]
    @user = User.where(email_address: email_address).first
    if @user && !@user.sso_flag
      @user.token = ''
      @user.token = @user.generate_token
      @user.save(validate: false)
      UserMailer.reset_password_email(@user, current_language).deliver
    end
    redirect_to login_url, notice: t('__alert_reset_password_email__')
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    redirect_to login_url unless ENABLE_USER_REGISTRATION
    @user = User.new
    @selectable_roles = Language.where(name: current_language.to_s).take.roles.selectable
    @selectable_roles = Role.default unless @selectable_roles.present?
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    # honeypot
    return head :ok, content_type: 'text/html' if params[:alternative_name].present?

    @user = User.new(user_params)

    @user.role_id = Role.where(token: params[:role_token]).take.id
    respond_to do |format|
      if @user.save
        logger.debug('@user.token: ' + @user.token)
        @user.set_role
        # everyone = AccessLevel.where(name: 'everyone')
        # @user.access_levels << everyone.first if everyone.count == 1
        if ENABLE_USER_APPROVAL
          UserMailer.user_registration_approval_request_email(@user, current_language).deliver
          UserMailer.user_registration_approval_notification_email(@user, current_language).deliver
          format.html { redirect_to login_url, notice: t('__alert_email_approval_user__') }
        else
          UserMailer.user_registration_activation_email(@user, current_language).deliver
          UserMailer.user_registration_notification_email(@user, current_language).deliver
          format.html { redirect_to login_url, notice: t('__alert_email_activation__') }
        end
      else
        @selectable_roles = Language.where(name: current_language.to_s).take.roles.selectable
        @selectable_roles = Role.default unless @selectable_roles.present?
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # Get /users/
  def activate
    token = params[:activation_string]
    @user = User.find_by(token: token)
    logger.debug('@user.token: ' + @user.token)
    if @user
      @user.activated = true
      @user.token = nil
      @user.save
      UserMailer.user_activation_successful_email(@user, current_language).deliver
      redirect_to login_url, notice: t('__alert_success_user_activation__')
    else
      redirect_to login_url, notice: t('__alert_failed_user_activation__')
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    # @user = User.find(current_user.id)
    # @user = User.find(params[:id]) if params[:id]
    # if params[:activation_string]
    #   token = params[:activation_string]
    #   @user = User.find_by(:token => token )
    # end

    respond_to do |format|
      @user.update_attributes(user_params)
      if @user.valid?
        if params[:id]
          # legacy scaffolding scenario redirecting to edit
          @user.save
          format.html { redirect_to @user, notice: t('__alert_updated_user__') }
          format.json { head :no_content }
        else
          # update successful and returning to profile page
          @user.update_profile_flag = false
          @user.save
          format.html { redirect_to profile_path }
        end
      else
        if params[:source_page] == 'profile'
          # update failed, returning to profile page with errors
          format.html { render 'profile', notice: t('__alert_updated_user__') }
        else
          # update failed, returning to registration page with errors
          format.html { render action: 'edit' }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  # GET /profile
  def profile
    @user = current_user
    @facebook_account = ''
    @twitter_account = ''
    @youtube_account = ''
    @email_list = EmailList.new.sheet
    @email_list.use_action_status = false
    @email_list.success_action_redirect = url_for controller: 'email_lists', action: 'create_list'
    @marketing_emails = @user.marketing_emails
    @orders = @user.orders.history
    @contact_types = ContactType.all
    @contacts = []
    respond_to do |format|
      format.html # profile.html.erb
    end
  end

  # GET /update_profile
  def update_profile
    respond_to do |format|
      format.html { redirect_to '/', notice: t('__alert_updated_user__') } # profile.html.erb
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def get_user_by_token
    @user = User.find_by(token: params[:activation_string]) if params[:activation_string]
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id]) if params[:id]
    @user = User.find(current_user.id) unless @user
  end

  def admin_set_user
    @user = User.find(params[:admin_user_save_id]) if params[:admin_user_save_id]
  end

  def update_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_edit_user_params
    params.require(:user).permit(:first_name, :last_name, :title, :address_1, :address_2, :city, :state, :zip_code, :phone_number, :fax_number, :email_address, :email_address_confirmation, :username, :password, :password_confirmation, :ship_first_name, :ship_last_name, :ship_title, :ship_address_1, :ship_address_2, :ship_city, :ship_state, :ship_zip_code, :ship_phone_number, :ship_fax_number, :ship_email_address, :same_billing_shipping, :token, :activated, :user_type, :mobile_number, :website, :company_name, :country, :facebook_id, :linkedin_id, :twitter_id, access_level_ids: [])
  end    # Never trust parameters from the scary internet, only allow the white list through.

  def user_params
    params.require(:user).permit(:first_name, :last_name, :title, :address_1, :address_2, :city, :state, :zip_code, :phone_number, :fax_number, :email_address, :email_address_confirmation, :username, :password, :password_confirmation, :license_agreement_flag, :ship_first_name, :ship_last_name, :ship_title, :ship_address_1, :ship_address_2, :ship_city, :ship_state, :ship_zip_code, :ship_phone_number, :ship_fax_number, :ship_email_address, :same_billing_shipping, :token, :activated, :mobile_number, :website, :company_name, :email_address_confirmation, :country, :facebook_id, :linkedin_id, :twitter_id)
    # :user_type not added for protection, need to add directly through console
  end
end
