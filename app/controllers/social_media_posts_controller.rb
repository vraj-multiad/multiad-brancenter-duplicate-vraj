# class SocialMediaPostsController < ApplicationController
class SocialMediaPostsController < ApplicationController
  before_action :set_social_media_post, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?, except: [:shared_page, :shared_page_asset_preview]
  before_action :superuser?, only: [:index, :show, :new, :edit, :update, :destroy]

  def shared_page
    token = params[:asset_id]
    # Need to create a different index table once we get videos
    @shared_page_view_token = ''
    @assets = []
    @asset = SharedPage.where(token: token).where('expiration_date > ?', Time.zone.now).first
    if @asset
      logger.debug 'shared_page'
      @shared_page_token = @asset.token
      shared_page_view = @asset.shared_page_views.create!(reference: params[:reference])
      @shared_page_view_token = shared_page_view.token
      @asset.shared_page_items.each do |shared_page_item|
        @assets.push LoadAsset.load_asset(type: shared_page_item.shareable_type, id: shared_page_item.shareable_id)
      end
    end
    unless @asset
      logger.debug 'dl_image_group'
      @asset = DlImageGroup.where(token: token).first
      @assets = [@asset]
    end
    unless @asset
      logger.debug 'user_uploaded_image'
      @asset = UserUploadedImage.where(token: token).first
      @assets = [@asset]
    end
    unless @asset
      logger.debug 'dl_image'
      @asset = DlImage.where(token: token).first
      @assets = [@asset]
    end
    unless @asset
      logger.debug 'kwikee_product'
      @asset = KwikeeProduct.where(token: token).first
      @assets = [@asset]
    end
    render 'shared_page', layout: 'includes_only'
    # format.html { render 'shared_page' }
  end

  def shared_page_asset_preview
    shared_page_asset_preview_params
    page = SharedPage.where(token: params[:shared_page_token]).first
    @shared_page_view_token = params[:shared_page_view_token]
    raise if @shared_page_view_token.present? && page.shared_page_views.find_by(token: @shared_page_view_token).nil?
    @asset = page
    @shared_page_token = page.token

    @parent_asset = LoadAsset.load_asset(type: params[:shared_page_parent_item_type], token: params[:shared_page_parent_item_token]) if params[:shared_page_parent_item_type].present? && params[:shared_page_parent_item_token].present?
    item = LoadAsset.load_asset(type: params[:shared_page_item_type], token: params[:shared_page_item_token])
    @asset = item.kwikee_product if item.class.name == 'KwikeeAsset'
    if page.present?
      permitted = @parent_asset.dl_images.where(id: item.id).present? if @parent_asset.present? && @parent_asset.class.name == 'DlImageGroup'
      permitted = @parent_asset.kwikee_assets.where(id: item.id).present? if @parent_asset.present? && @parent_asset.class.name == 'KwikeeProduct'
      if item.present? && (permitted || page.shared_page_items.where(shareable_type: item.class.name, shareable_id: item.id).present?)
        if item.class.name == 'DlImageGroup'
          @parent_asset = item
          @asset = page
          @assets = item.dl_images.where(is_shareable_via_email: true).user_permitted(page.user.id).where(status: 'production')
          # stub for shreable_via_social_media # no clients have social_media yet
          # @assets = item.dl_images.where(is_shareable_via_social_media: true).user_permitted(page.user.id).where(status: 'production')
          return render partial: 'shared_page_image_group_details'
        elsif item.class.name == 'KwikeeProduct'
          @parent_asset = item
          @asset = item
          @assets = item.kwikee_assets
          return render partial: 'shared_page_kwikee_product_details'
        else
          @assets = [item]
        end
      end
    else
      @assets = [item]
      # @asset = item unless @asset # need to allow movie preview, don't have time to test this fix and its impact on stats.
    end
    render partial: 'shared_page_asset_preview'
  end

  # GET /social_media_posts
  # GET /social_media_posts.json
  def index
    @social_media_posts = SocialMediaPost.all
  end

  # GET /social_media_posts/1
  # GET /social_media_posts/1.json
  def show
  end

  # GET /social_media_posts/new
  def new
    @social_media_post = SocialMediaPost.new
  end

  # GET /social_media_posts/1/edit
  def edit
  end

  # GET /social_media_posts/new
  def share
    @social_media_post = SocialMediaPost.new

    @current_user = current_user

    @shared_assets = []
    @share_type = 'single_item'
    @category = params[:category]
    @share_ids = []

    @shareable_via_email_assets = []
    @shareable_via_social_media_assets = []
    @not_shareable_via_email_assets = []
    @not_shareable_via_social_media_assets = []

    @share_ids.push params[:asset_type].to_s + '|' + params[:token] if %w(DlImageGroup KwikeeProduct).include?(params[:asset_type])

    logger.debug 'facebook: ' + @current_user.facebook_account.id.to_s
    logger.debug 'twitter: ' + @current_user.twitter_account.id.to_s
    logger.debug 'youtube: ' + @current_user.youtube_account.id.to_s

    @facebook_post_as_options = []
    @facebook_post_as_default = ''
    if current_user.facebook_account.logged_in?
      facebook_me = [
        current_user.facebook_account.profile_name,
        '',
        { 'data-image' => current_user.facebook_account.profile_image }
      ]
      @facebook_post_as_options.push facebook_me
      current_user.facebook_account.facebook_pages.each do |page|
        facebook_page = [
          page.profile_name,
          page.id,
          { 'data-image' => page.profile_image }
        ]
        @facebook_post_as_options.push facebook_page
      end

      # sort by profile/page name
      @facebook_post_as_options = @facebook_post_as_options.sort { |x, y| x[0] <=> y[0] }

      # set default to last used
      facebook_default = (([current_user.facebook_account] + current_user.facebook_account.facebook_pages).sort { |x, y|  y.last_used.to_i <=> x.last_used.to_i }).first
      @facebook_post_as_default = facebook_default.id unless facebook_default.id == current_user.facebook_account.id || facebook_default.last_used.nil?
    end

    if !@category.nil?
      user_keywords = @current_user.user_keywords.where(term: @category.downcase, user_keyword_type: 'category')
      user_keywords.each do |uc|
        asset = LoadAsset.load_asset(type: uc.categorizable_type, id: uc.categorizable_id)
        @share_ids.push uc.categorizable_type + '|' + asset.token
      end
    else
      # use asset_group
      asset_group = current_asset_group
      logger.debug asset_group
      asset_group.each do |asset_type, asset_items|
        asset_items.each do |asset_token, _status|
          asset = LoadAsset.load_asset(type: asset_type, token: asset_token)
          next unless asset.shareable?
          @share_ids.push asset_type + '|' + asset_token
        end
      end
    end

    if @share_ids.present? && @share_ids.length > 0
      @share_type = 'page'
      # create page
      @shared_page = SharedPage.create!(user_id: current_user.id)
      @email_subject = ''
      @share_ids.each do |s|
        type, token = s.split('|')
        asset = LoadAsset.load_asset(type: type, token: token)
        @email_subject = asset.title.to_s if @share_ids.length == 1

        if asset.shareable_via_email?
          @shareable_via_email_assets << asset.title
        else
          @not_shareable_via_email_assets << asset.title
        end

        if asset.shareable_via_social_media?
          @shareable_via_social_media_assets << asset.title
        else
          @not_shareable_via_social_media_assets << asset.title
        end

        if asset.shareable_via_email? || asset.shareable_via_social_media?
          shared_page_item = SharedPageItem.create!(shareable_id: asset.id, shareable_type: type, shared_page_id: @shared_page.id)
          if asset.class.name == 'DlImageGroup'
            shared_asset = { asset_type: type, asset_id: asset.id, asset_preview: asset.share_preview(current_user.id), asset_share_link: asset.share_url(current_user.id), @video => asset.video?, @image => asset.image? }
          else
            shared_asset = { asset_type: type, asset_id: asset.id, asset_preview: asset.share_preview, asset_share_link: asset.share_url, @video => asset.video?, @image => asset.image? }
          end
          @shared_assets.push shared_asset
        end

        logger.debug shared_page_item.inspect
      end

      return no_shareable_items unless @shareable_via_email_assets.present? || @shareable_via_social_media_assets.present?

      @token = @shared_page.token
      @asset_type = 'SharedPage'
      @video = 'false'
      @image = 'false'
      @file = 'false'
      @page = 'true'
      @asset_email_link = shared_assets_page_url + '?reference=email&asset_id=' + @shared_page.token
      @asset_share_link = shared_assets_page_url + '?reference=share&asset_id=' + @shared_page.token
      @asset_email_copy_link = @asset_share_link
      @asset_preview = ''
      @extension = ''
      @title = ''
      return render partial: 'share', content_type: 'text/html'
    end

    @asset_type = params[:asset_type]
    @token = params[:token]
    asset = LoadAsset.load_asset(type: @asset_type, token: @token)

    return no_shareable_items unless asset.present?

    if asset.shareable_via_email?
      @shareable_via_email_assets << asset.title
    else
      @not_shareable_via_email_assets << asset.title
    end

    if asset.shareable_via_social_media?
      @shareable_via_social_media_assets << asset.title
    else
      @not_shareable_via_social_media_assets << asset.title
    end

    return no_shareable_items unless @shareable_via_email_assets.present? || @shareable_via_social_media_assets.present?

    @asset_preview = params[:asset_preview]
    @asset_share_link = params[:asset_share_link]
    if asset.shareable_via_email?
      # setup shared page with a single item so we may expire it.
      emailed_page = SharedPage.create!(user_id: current_user.id)
      SharedPageItem.create!(shareable_id: asset.id, shareable_type: @asset_type, shared_page_id: emailed_page.id)
      @asset_email_link = shared_assets_page_url + '?reference=email&asset_id=' + emailed_page.token
      @asset_email_copy_link = shared_assets_page_url + '?reference=share&asset_id=' + emailed_page.token
    end
    @video = params[:video]
    @image = params[:image]
    @file = params[:file]
    @page = 'false'
    @extension = params[:extension]
    @title = params[:title]
    @email_subject = asset.title.to_s

    render partial: 'share', content_type: 'text/html'
  end

  def no_shareable_items
    render partial: 'no_shareable_items', content_type: 'text/html'
  end

  def post
    @post = nil

    create_params = post_params

    # asset_id is intentionally omitted from mass assignment
    # should include some mechanism for ensuring a user should be able to share the asset being requested

    asset = LoadAsset.load_asset(type: params[:asset_type], token: params[:token])

    logger.debug asset.inspect

    create_params['asset_id'] = asset.id

    logger.debug "create_params: #{create_params.to_yaml} " + create_params.inspect

    async = true
    if params[:via] == 'twitter'
      create_params[:social_media_account_id] = current_user.twitter_account.id
      @post = TwitterPost.create(create_params)
    elsif params[:via] == 'facebook'
      facebook_account_id = current_user.facebook_account.id
      if params[:facebook_page_id] != ''
        # must have this security check
        facebook_page = FacebookPage.where(facebook_account_id: facebook_account_id, id: params[:facebook_page_id]).first
        facebook_account_id = facebook_page.id
        facebook_page.last_used = Time.now
        facebook_page.save!
      else
        current_user.facebook_account.last_used = Time.now
        current_user.facebook_account.save!
      end
      create_params[:social_media_account_id] = facebook_account_id
      @post = FacebookPost.create(create_params)
    elsif params[:via] == 'youtube'
      create_params[:social_media_account_id] = current_user.youtube_account.id
      @post = YoutubePost.create(create_params)
    elsif params[:via] == 'email'
      #### need to register a request for a new email share request.
      # store recipient
      # share page url
      # return  emailer
      if params[:email_address] && params[:share_email_link]
        @post = {}
        UserMailer.social_media_post_email(params[:share_email_link], params[:email_address], create_params['description'], current_user, current_language, params[:email_subject]).deliver
        async = false
        @post['success'] = params[:share_email_link]
      else
        @post['error'] = 'provided email_address is invalid.'
      end
    else
      raise
    end

    SocialMediaWorker.perform_async('post', 'social_media_post', @post.id) if async

    render partial: 'share_thanks'
  end

  def status
    logger.debug params.inspect
    @post = SocialMediaPost.where(
      social_media_account_id: [
        current_user.facebook_account.id,
        current_user.twitter_account.id,
        current_user.youtube_account.id,
        current_user.facebook_account.facebook_pages.map(&:id)
      ],
      id: params[:id]
    ).first
    render partial: 'share_thanks'
  end

  # # POST /social_media_posts
  # # POST /social_media_posts.json
  # def create
  #   @social_media_post = SocialMediaPost.new(social_media_post_params)

  #   respond_to do |format|
  #     if @social_media_post.save
  #       format.html { redirect_to @social_media_post, notice: 'Social media post was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @social_media_post }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @social_media_post.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /social_media_posts/1
  # PATCH/PUT /social_media_posts/1.json
  def update
    respond_to do |format|
      if @social_media_post.update(social_media_post_params)
        format.html { redirect_to @social_media_post, notice: 'Social media post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @social_media_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /social_media_posts/1
  # DELETE /social_media_posts/1.json
  def destroy
    @social_media_post.destroy
    respond_to do |format|
      format.html { redirect_to social_media_posts_url }
      format.json { head :no_content }
    end
  end

  private

  def shared_page_asset_preview_params
    [params.require(:shared_page_token), params.require(:shared_page_item_type), params.require(:shared_page_item_token)]
  end

  def post_params
    params.require(:social_media_post).permit(:title, :description, :asset_type)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_social_media_post
    @social_media_post = SocialMediaPost.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def social_media_post_params
    params.require(:social_media_post).permit(:social_media_account_id, :description, :finished_at, :error, :type, :asset_id, :title, :success, :asset_type)
  end
end
