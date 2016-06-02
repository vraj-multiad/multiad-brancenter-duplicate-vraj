class SocialMediaAccountsController < ApplicationController
  before_action :set_social_media_account, only: [:show, :edit, :update, :destroy]


  def facebook_callback
    auth_hash = env['omniauth.auth']
    logger.debug "auth_hash:\n #{auth_hash.to_yaml}"
    
    current_user.facebook_account.update_from_auth_hash auth_hash
    
    flash[:auth_success] = 'Logged in successfully.'
    redirect_to profile_path
  end
  
  def twitter_callback
    auth_hash = env['omniauth.auth']
    logger.debug "auth_hash:\n #{auth_hash.to_yaml}"
    
    current_user.twitter_account.update_from_auth_hash auth_hash
    
    flash[:auth_success] = 'Logged in successfully.'
    redirect_to profile_path
  end
  
  def youtube_callback
    auth_hash = env['omniauth.auth']
    logger.debug "auth_hash:\n #{auth_hash.to_yaml}"
    
    current_user.youtube_account.update_from_auth_hash auth_hash
    
    flash[:auth_success] = 'Logged in successfully.'
    redirect_to profile_path
  end
  
  def auth_fail
    flash[:auth_fail] = 'Login failed. ' + params[:message]
    redirect_to profile_path
  end

  def facebook_logout
    current_user.facebook_account.logout!
    redirect_to profile_path
  end
  
  def twitter_logout
    current_user.twitter_account.logout!
    redirect_to profile_path
  end
  
  def youtube_logout
    current_user.youtube_account.logout!
    redirect_to profile_path
  end

  # def index
  #   @facebook_account = current_user.facebook_account
  #   @twitter_account  = current_user.twitter_account
  #   @youtube_account  = current_user.youtube_account
  # end
  

  # GET /social_media_accounts
  # GET /social_media_accounts.json
  def index
    @social_media_accounts = SocialMediaAccount.all
  end

  # GET /social_media_accounts/1
  # GET /social_media_accounts/1.json
  def show
  end

  # GET /social_media_accounts/new
  def new
    @social_media_account = SocialMediaAccount.new
  end

  # GET /social_media_accounts/1/edit
  def edit
  end

  # POST /social_media_accounts
  # POST /social_media_accounts.json
  def create
    @social_media_account = SocialMediaAccount.new(social_media_account_params)

    respond_to do |format|
      if @social_media_account.save
        format.html { redirect_to @social_media_account, notice: 'Social media account was successfully created.' }
        format.json { render action: 'show', status: :created, location: @social_media_account }
      else
        format.html { render action: 'new' }
        format.json { render json: @social_media_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /social_media_accounts/1
  # PATCH/PUT /social_media_accounts/1.json
  def update
    respond_to do |format|
      if @social_media_account.update(social_media_account_params)
        format.html { redirect_to @social_media_account, notice: 'Social media account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @social_media_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /social_media_accounts/1
  # DELETE /social_media_accounts/1.json
  def destroy
    @social_media_account.destroy
    respond_to do |format|
      format.html { redirect_to social_media_accounts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_social_media_account
      @social_media_account = SocialMediaAccount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def social_media_account_params
      params.require(:social_media_account).permit(:expires_at, :oauth_refresh_token, :oauth_secret, :oauth_token, :profile_image, :profile_name, :user_id, :uid, :type)
    end
end
