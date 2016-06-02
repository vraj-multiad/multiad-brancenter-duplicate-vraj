# class UserKeywordsController < ApplicationController
class UserKeywordsController < ApplicationController
  before_action :set_user_keyword, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?, except: [:categorize_init, :categorize, :categorize_assets, :categorize_multiple, :add_to_favorites]

  def categorize_init
    categorize = init_categorize
    logger.debug categorize
    render nothing: true
  end

  def add_to_favorites
    categorizable_type = params[:categorizable_type]
    token = params[:token]

    @asset = LoadAsset.load_asset(token: token, type: categorizable_type)

    is_favorite = current_user.user_keywords.where(categorizable_type: categorizable_type, categorizable_id: @asset.id, user_keyword_type: 'category', term: 'favorites', title: 'Favorites')

    case is_favorite.count
    when 0
      create_hash = { user_id: current_user.id, title: 'Favorites', term: 'favorites', categorizable_type: categorizable_type, categorizable_id: @asset.id, user_keyword_type: 'category' }
      logger.debug 'create_hash: ' + create_hash.inspect
      uk = UserKeyword.new create_hash
      uk.save
    when 1
      is_favorite.destroy_all
    else
      logger.debug 'should not have the same category twice'
    end

    # @categorize = set_categorize(categorizable_type, token)
    logger.debug 'add_to_favorites: ' + @asset.inspect
    render nothing: true
  end

  def categorize_multiple
    # previously done in UserUploadedImagesController#add_to_library
    images = current_user.user_uploaded_images.where(token: params[:tokens])
    images.each do |image|
      image.status = 'complete'
      image.save!
      set_asset_group('UserUploadedImage', image.token)
    end

    @current_categorize = current_asset_group
    categorize_helper
  end

  def categorize
    @categorizable_type = params[:categorizable_type]
    @token = params[:token]

    if @categorizable_type.present? && @token.present?
      # single op support
      @current_categorize = { @categorizable_type => { @token => 'active'} }
    else
      @current_categorize = current_asset_group
    end
    categorize_helper
  end

  def categorize_assets
    operation = params[:operation]
    @user_terms = {}
    @user_terms[:keyword] = params[:keyword]
    @user_terms[:category] = params[:category]
    # @user_keywords = params[:keyword]
    # @user_categories = params[:category]
    @categorized_assets = params[:categorized_asset]
    user = current_user
    user_id = user.id

    @categorized_assets.each do |asset_type_and_token|
      asset_type, token = asset_type_and_token.split('|')
      asset = LoadAsset.load_asset(type: asset_type, token: token)

      # get current user_keywords (type keyword) for asset

      asset_keywords = {}
      asset_keywords[:keyword] = asset.user_keywords.where(user_id: user_id, user_keyword_type: 'keyword').pluck(:term)
      asset_keywords[:category] = asset.user_keywords.where(user_id: user_id, user_keyword_type: 'category').pluck(:term)

      asset_titles = {}
      asset_titles[:keyword] = asset.user_keywords.where(user_id: user_id, user_keyword_type: 'keyword').pluck(:title)
      asset_titles[:category] = asset.user_keywords.where(user_id: user_id, user_keyword_type: 'category').pluck(:title)

      @user_terms.each do |user_keyword_type, user_keyword_terms|
        user_keyword_terms_array = user_keyword_terms.split(',') - ['', ' ', nil]
        # logger.debug '=========================================='
        # logger.debug user_keyword_type.to_s + ' ---- ' + user_keyword_terms_array.inspect
        # logger.debug '=========================================='

        case operation
        when 'add'
          # @user_terms[user_keyword_type].split(',').each do |t|
          user_keyword_terms_array.each do |t|
            user_keyword_term = t.strip
            logger.debug 'user_keyword_term>' + user_keyword_term.to_s + '<'
            next if user_keyword_term.nil? || user_keyword_term == ''
            # iterate over keywords and test include?
            # logger.debug 'here are the titles: ' + asset_keywords[user_keyword_type].inspect
            # logger.debug 'does it include: >' + user_keyword_term.to_s + '< ' + asset_titles[user_keyword_type].include?(user_keyword_term).to_s
            unless asset_titles[user_keyword_type].include?(user_keyword_term)
              ## fixup all previous titles to last man standing
              fixup_terms = user.user_keywords.where(term: user_keyword_term.downcase)
              fixup_terms.each do |term|
                term.title = user_keyword_term
                term.save
              end
            end
            # list now includes current term, preventing race condition of adding This and this in same operation
            # Did fixup convert existing keyword? if not create a new one
            # logger.debug 'here are the keywords: ' + asset_keywords[user_keyword_type].inspect
            # logger.debug 'does it include: >' + user_keyword_term.to_s + '< ' + asset_keywords[user_keyword_type].include?(user_keyword_term.downcase).to_s
            next if asset_keywords[user_keyword_type].include?(user_keyword_term.downcase)
            # create new user_keyword
            create_hash = { user_id: user_id, title: user_keyword_term, term: user_keyword_term.downcase, categorizable_type: asset_type, categorizable_id: asset.id, user_keyword_type: user_keyword_type }
            logger.debug 'create_hash: ' + create_hash.inspect
            uk = UserKeyword.new create_hash
            uk.save
            asset_titles[user_keyword_type].push user_keyword_term
            asset_keywords[user_keyword_type].push user_keyword_term.downcase
          end
        when 'remove'

          ### do we have terms to potentially remove?
          if asset_keywords[user_keyword_type].length > 0
            user_keyword_terms_array.map!(&:downcase)
            remove_terms = asset_keywords[user_keyword_type] - user_keyword_terms_array
            logger.debug asset_keywords[user_keyword_type].inspect + ' - ' + user_keyword_terms_array.inspect + ' = ' + remove_terms.inspect

            next unless remove_terms.length > 0
            remove_terms.each do |remove_term|
              asset.user_keywords.where(user_id: user_id, user_keyword_type: user_keyword_type, term: remove_term.downcase).destroy_all
            end
          end

        end
        #### update UserUploadedImage Category and Keyword counts
        next unless asset_type == 'UserUploadedImage'
        category_count = asset.user_keywords.where(user_id: user_id, user_keyword_type: 'category').count
        keyword_count = asset.user_keywords.where(user_id: user_id, user_keyword_type: 'keyword').count
        asset.category_count = category_count
        asset.keyword_count = keyword_count
        asset.save
      end
    end

    categorize
  end

  # GET /user_keywords
  # GET /user_keywords.json
  def index
    @user_keywords = UserKeyword.all
  end

  # GET /user_keywords/1
  # GET /user_keywords/1.json
  def show
  end

  # GET /user_keywords/new
  def new
    @user_keyword = UserKeyword.new
  end

  # GET /user_keywords/1/edit
  def edit
  end

  # POST /user_keywords
  # POST /user_keywords.json
  def create
    @user_keyword = UserKeyword.new(user_keyword_params)

    respond_to do |format|
      if @user_keyword.save
        format.html { redirect_to @user_keyword, notice: 'User keyword was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user_keyword }
      else
        format.html { render action: 'new' }
        format.json { render json: @user_keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_keywords/1
  # PATCH/PUT /user_keywords/1.json
  def update
    respond_to do |format|
      if @user_keyword.update(user_keyword_params)
        format.html { redirect_to @user_keyword, notice: 'User keyword was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user_keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_keywords/1
  # DELETE /user_keywords/1.json
  def destroy
    @user_keyword.destroy
    respond_to do |format|
      format.html { redirect_to user_keywords_url }
      format.json { head :no_content }
    end
  end

  private

  def categorize_helper
    user_id = current_user.id
    @asset_objs = []
    @keywords = []
    @categories = []
    @all_categories = UserKeyword.category.where(user_id: user_id).pluck(:title)
    @all_categories.uniq!

    @all_keywords = UserKeyword.keyword.where(user_id: user_id).pluck(:term)
    @all_keywords.uniq!

    @current_categorize.each do |categorizable_type, tokens|
      next if categorizable_type == 'KwikeeAsset'
      tokens.each do |token, _v|
        asset = LoadAsset.load_asset(type: categorizable_type, token: token)
        if asset.present?
          asset_obj = {
            key: categorizable_type.to_s + '|' + token.to_s,
            asset: asset,
            keywords: asset.user_keywords.where(user_id: user_id, user_keyword_type: 'keyword').pluck(:term),
            categories: asset.user_keywords.where(user_id: user_id, user_keyword_type: 'category').pluck(:title)
          }
          @asset_objs.push asset_obj

          @keywords.push asset.user_keywords.where(user_id: user_id, user_keyword_type: 'keyword').pluck(:term)
          @categories.push asset.user_keywords.where(user_id: user_id, user_keyword_type: 'category').pluck(:title)
        else
          logger.error "asset #{categorizable_type} with token #{token} not found"
        end
      end
    end

    @asset_objs.each do |x|
      logger.debug 'categorize_submit: '
      x.each do |k, v|
        logger.debug '=== ' + k.to_s + ': ' + v.inspect
      end
    end

    @keyword_string = @keywords.uniq.sort.join(',')
    @category_string = @categories.uniq.sort.join(',')

    render partial: 'categorize', content_type: 'text/html'
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user_keyword
    @user_keyword = UserKeyword.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_keyword_params
    params.require(:user_keyword).permit(:term, :categorizable_id, :categorizable_type, :user_id, :user_keyword_type, :title)
  end
end
