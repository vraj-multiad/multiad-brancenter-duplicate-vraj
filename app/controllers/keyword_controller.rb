# class KeywordController < ApplicationController
class KeywordController < ApplicationController
  include KeywordSearchInit
  before_action :logged_in?
  before_action :contributor?, only: [:admin, :admin_ac_image, :admin_assets, :admin_dl_image]
  before_action :superuser?, only: [:index]

  def admin_refresh
    admin_keyword_helper
    render partial: 'admin', content_type: 'text/html'
  end

  def admin_ac_image
    AcImage.where(token: params[:tokens]).each do |image|
      image.status = image.calc_status
      image.save!
      set_asset_group('AcImage', image.token)
    end

    admin
  end

  def admin_dl_image
    DlImage.where(token: params[:tokens]).each do |image|
      image.status = image.calc_status
      image.save!
      set_asset_group('DlImage', image.token)
    end

    admin
  end

  def admin
    admin_keyword_helper

    render partial: 'admin', content_type: 'text/html'
  end

  def admin_keyword_types
    admin_keyword_helper
    render partial: 'admin_keyword_types', content_type: 'text/html'
  end

  def admin_assets
    operation = params[:operation]
    categorized_assets = params[:categorized_asset]
    access_level = params[:access_level]
    terms = {}
    keyword_types = KeywordType.all.pluck(:name)
    keyword_types.each do |keyword_type|
      terms[keyword_type] = params[keyword_type]
    end

    categorized_assets.each do |asset_type_and_token|
      asset_type, token = asset_type_and_token.split('|')
      asset = LoadAsset.load_asset(type: asset_type, token: token)
      asset.update_attribute(:updated_at, Time.now)
      keyword_prefix = asset.keyword_prefix
      # get current keywords for asset
      asset_keywords = {}
      keyword_types.each do |keyword_type|
        logger.debug 'keyword_type: ' + "(#{keyword_prefix})" + keyword_type.to_s
        if keyword_type == 'search'
          asset_keywords[keyword_prefix + keyword_type] = asset.keywords.where(keyword_type: keyword_prefix + keyword_type).pluck(:term)
        else
          permitted_keyword_terms = current_user.permitted_keyword_type keyword_type
          if permitted_keyword_terms.count > 0 && operation == 'remove'
            asset_keywords[keyword_prefix + keyword_type] = permitted_keyword_terms.pluck(:term)
          else
            asset_keywords[keyword_prefix + keyword_type] = asset.keywords.where(keyword_type: keyword_prefix + keyword_type).pluck(:term)
          end
        end
      end

      terms.each do |keyword_type, keyword_terms|
        next if keyword_terms.nil?
        keyword_terms_array = keyword_terms.split(',') - ['', ' ', nil]
        case operation
        when 'add'
          keyword_terms_array.each do |t|
            keyword_term = t.strip
            next if asset_keywords[keyword_prefix + keyword_type].include?(keyword_term.downcase)
            create_hash = { term: keyword_term.downcase, keyword_type: keyword_prefix + keyword_type, searchable_type: asset_type, searchable_id: asset.id }
            k = Keyword.new create_hash
            k.save
            asset_keywords[keyword_prefix + keyword_type].push keyword_term.downcase
          end
          if access_level.present?
            access_level_count = asset.asset_access_levels.where(access_level_id: access_level).count
            if access_level_count == 0
              create_hash = { access_level_id: access_level, restrictable_type: asset.class.name, restrictable_id: asset.id }
              aal = AssetAccessLevel.new create_hash
              aal.save
            end
          end
        when 'remove'

          ### do we have terms to potentially remove?
          if asset_keywords[keyword_prefix + keyword_type].length > 0
            keyword_terms_array.map!(&:downcase)
            asset_keywords_downcase = asset_keywords[keyword_prefix + keyword_type].map(&:downcase)
            remove_terms = asset_keywords_downcase - keyword_terms_array
            logger.debug operation + ':' + keyword_prefix + keyword_type + ':' + asset_keywords_downcase.inspect + ' - ' + keyword_terms_array.inspect + ' = ' + remove_terms.inspect

            if remove_terms.length > 0
              remove_terms.each do |remove_term|
                asset.keywords.where(keyword_type: keyword_prefix + keyword_type, term: remove_term).destroy_all
              end
            end
          end
          if access_level.present?
            access_level = access_level.gsub(/\s+/, '')
            access_level_array = (access_level.split(',') - ['', ' ', nil]).map(&:to_i)
            logger.debug 'asset.asset_access_levels.pluck(:access_level_id): ' + asset.asset_access_levels.pluck(:access_level_id).to_s
            logger.debug 'access_level_array: ' + access_level_array.to_s
            remove_access_levels = asset.asset_access_levels.pluck(:access_level_id) - access_level_array
            asset.asset_access_levels.where(access_level_id: remove_access_levels).destroy_all
          end

        end
      end
      asset.save
    end

    admin
  end

  def index
    @keywords = Keyword.all
    @categories = Keyword.category
    @searches = Keyword.search
    @media_types = Keyword.media_type
    @topics = Keyword.topic
  end

  def home_search
  end

  def my_library_search
  end

  def my_documents_search
  end

  def asset_preview
    token = params[:token]
    type = params[:type]
    @exclude_download = false
    @exclude_download = true if params[:preview]
    @asset = LoadAsset.load_asset(token: token, type: type)
    @current_asset_group = current_asset_group
    if @asset.class.name == 'DlImageGroup' && @asset.dl_images.present?
      @assets = @asset.dl_images.user_permitted(current_user.id)
      render partial: 'image_group_details'
    elsif @asset.class.name == 'KwikeeProduct'
      @assets = @asset.kwikee_assets
      render partial: 'kwikee_product_details'
    else
      @assets = [@asset]
      render partial: 'asset_preview'
    end
  end

  def search_filters
    keyword_search_init
    @no_search = true
    @update_search_filters = true

    render partial: 'search_filters'
  end

  def search
    uncategorized, no_access_levels = keyword_search_init

    # @current_user = current_user
    @all_user_categories = current_user.user_keywords.category.order('title asc')
    @all_user_categories_list = []
    @user_categories_title = t '__category_filter__'
    @user_categories_title = @user_categories[0] unless @user_categories.nil? || @user_categories == ['']

    keyword_results = []
    user_keyword_results = []
    category_results = []
    media_type_results = []
    topic_results = []

    keyword_type_flag = @my_contributions == ['my-contributions'] || current_user.admin? || current_user.superuser?

    ####### sorting
    # fundamental array math [['a', 1], ['b', 3], ['d', 1]] & [['d',1], ['a',1]] = [['a', 1], ['d', 1]]
    keyword_index = KeywordIndex.get_index(params[:sort].to_s)

    access_level_results = []
    if @access_levels.count > 0 && !current_user.superuser? || (current_user.superuser? && @search_access_levels.present?)
      access_ids = @search_access_levels.present? ? @search_access_levels : @access_levels.pluck(:id)
      if no_access_levels
        access_level_results = (current_user.dl_images.pluck(:id).map! { |id| ['DlImage', id] } - AssetAccessLevel.where(access_level_id: access_ids).pluck('distinct restrictable_type, restrictable_id'))
      else
        everyone_id = AccessLevel.where(name: 'everyone').pluck(:id)[0]
        access_ids << everyone_id unless access_ids.include?(everyone_id)
        access_level_results = AssetAccessLevel.where(access_level_id: access_ids).pluck('distinct restrictable_type, restrictable_id')
        # add your contributed content if not explicitly access level driven
        access_level_results = (access_level_results + current_user.dl_images.pluck(:id).map! { |id| ['DlImage', id] } + current_user.user_uploaded_images.pluck(:id).map! { |id| ['UserUploadedImage', id] }).uniq unless @search_access_levels.present?
      end
    end

    key_results = {}
    if @topics && @topics != ['']
      # topics are subtractive, but not multi-selectable
      search_term = @topics[0]
      topic_results = Keyword.where(term: search_term, keyword_type: Keyword.keyword_types('topic', keyword_type_flag))
      key_results['topic:' + search_term] = topic_results.pluck('distinct searchable_type, searchable_id') if topic_results

      # search by sub_term since it is more specific
      if @sub_topics && @sub_topics != ['']
        search_term = @sub_topics[0]
        topic_results = Keyword.where(term: search_term, keyword_type: Keyword.keyword_types('topic', keyword_type_flag))
        key_results['topic:' + search_term] = topic_results.pluck('distinct searchable_type, searchable_id') if topic_results
      end
    end
    if @media_types && @media_types != ['']
      # media types are subtractive, but not multi-selectable
      search_term = @media_types[0]
      media_type_results = Keyword.where(term: search_term, keyword_type: Keyword.keyword_types('media_type', keyword_type_flag))
      key_results['media_type:' + search_term] = media_type_results.pluck('distinct searchable_type, searchable_id') if media_type_results

      # search by sub_term since it is more specific
      if @sub_media_types && @sub_media_types != ['']
        search_term = @sub_media_types[0]
        media_type_results = Keyword.where(term: search_term, keyword_type: Keyword.keyword_types('media_type', keyword_type_flag))
        key_results['media_type:' + search_term] = media_type_results.pluck('distinct searchable_type, searchable_id') if media_type_results
      end
    end

    #### user-library interface
    @categorized_results = {}
    if @user_content == ['user-content']
      @filter_type = 'user'
      # get uncategorized content
      if @group_results_by_user_category.to_s == '1'
        if @user_categories == ['']
          @uncategorized = current_user.user_uploaded_images.available.library.uncategorized.complete
          if @uncategorized.length > 0
            @all_user_categories_list.push 'uncategorized'
            @user_category_groups = [['uncategorized', -1]]
            @categorized_results['uncategorized'] = []
            @uncategorized.each do |u|
              @categorized_results['uncategorized'].push ['UserUploadedImage', u.id]
            end
          end
          @ac_images = current_user.user_uploaded_images.ac_image.complete.where(expired: false)
          if @ac_images.length > 0
            @all_user_categories_list.push 'adcreator images'
            @user_category_groups = [['adcreator images', 0]]
            @categorized_results['adcreator images'] = []
            @ac_images.each do |u|
              @categorized_results['adcreator images'].push ['UserUploadedImage', u.id]
            end
          end
        end
        @all_user_categories.each do |uc|
          if @user_categories && @user_categories != ['']
            next unless uc.title == @user_categories[0]
          end
          unless @categorized_results[uc.title]
            @all_user_categories_list.push uc.title
            @categorized_results[uc.title] = []
          end
          @categorized_results[uc.title].push [uc.categorizable_type, uc.categorizable_id]
        end
        @categorized_results.keys.each do |sort_key|
          next if sort_key == 'adcreator images'
          @categorized_results[sort_key] = keyword_index & @categorized_results[sort_key]
        end
      end

      # get user_categories results
      uc_results = []
      uc_key = 'all'
      if @user_categories.nil? || @user_categories == ['']
        uc_results = current_user.user_keywords.category
      else
        uc_key = @user_categories[0]
        uc_results = current_user.user_keywords.category.where(term: uc_key.downcase)
      end
      key_results['user_category:' + uc_key] = []
      uc_results.each do |u|
        key_results['user_category:' + uc_key].push [u.categorizable_type, u.categorizable_id]
      end
      key_results['user_category:' + uc_key] = keyword_index & key_results['user_category:' + uc_key] # sort

      @uploader = UserUploadedImage.new.image_upload
      @uploader.success_action_redirect = url_for controller: 'user_uploaded_images', action: 'upload_direct_library'
    end

    #### my_contributions interface
    if @my_contributions == ['my-contributions']
      @filter_type = 'search'
      contributions_key = 'category:user_contributions'
      mc_results = current_user.dl_images.available
      # mc_results = current_user.dl_images.where(status: 'production')
      if mc_results.count > 0
        key_results[contributions_key] = []
        mc_results.each do |result|
          key_results[contributions_key].push(['DlImage', result.id])
        end
        key_results[contributions_key] = keyword_index & key_results[contributions_key] # sort
      end
      @uploader = DlImage.new.bundle
      @uploader.success_action_redirect = url_for controller: 'dl_images', action: 'upload_direct_contributor'
    end

    #### ac_images interface
    if @ac_images == ['ac-images']
      @filter_type = 'ac_image'
      ac_images_key = 'category:ac_images'
      @limit = 50 if @keywords == ['']
      aci_results = AcImage.admin.pluck(:id)

      unless uncategorized.nil?
        uncat_results = AcImage.joins(:keywords).where(" keywords.keyword_type = '" + uncategorized + "'").pluck(:id)
        aci_results -= uncat_results
      end

      if aci_results.count > 0
        key_results[ac_images_key] = []
        aci_count = 0
        aci_results.each do |result|
          aci_count += 1
          break if aci_count.to_i > @limit.to_i
          key_results[ac_images_key].push(['AcImage', result])
        end
        key_results[ac_images_key] = keyword_index & key_results[ac_images_key] # sort
      end
      @uploader = AcImage.new.bundle
      @uploader.success_action_redirect = url_for controller: 'ac_images', action: 'admin_upload_direct_ac_image'
    end

    @categories.reject!(&:empty?)

    #### user_library interface (My saved ads)
    user_library_search = false
    user_library_results = []
    if 'user-library'.in?(@categories)
      user_library_search = true
      @categories.delete('user-library')
      user_uploaded_images = current_user.user_uploaded_images.available
      if user_uploaded_images
        user_uploaded_images.each do |ulr|
          user_library_results.push(['UserUploadedImage', ulr.id])
        end
      end
    end

    if @categories.size > 0
      # category search is additive use an in clause on the where to include multiple sections
      category_results = Keyword.where(term: @categories, keyword_type: Keyword.keyword_types('category', keyword_type_flag))

      if user_library_search
        # if category_results
        key_results['category:' + @categories.join('+') + '+user-library'] = category_results.pluck('distinct searchable_type, searchable_id') + user_library_results
      else
        key_results['category:' + @categories.join('+')] = category_results.pluck('distinct searchable_type, searchable_id') + user_library_results
      end
    elsif user_library_search # user-library only search
      key_results['category:user-library'] = user_library_results
    end
    #

    if @keywords.nil? || @keywords == ['']
      # Logic has changed we simply need some result
    else
      # or keywords are additive use an in clause on the where to include multiple sections
      # and keywords are subtractive utilize multiple arrays and intersection results to get all ids
      # separate full phrase results come first
      @phrase_match_results = keyword_search(@keywords[0], current_user, keyword_type_flag)

      @keywords.each do |keyword|
        keyword.split(/ +/).each do |split_keyword|
          keyword_search(split_keyword, current_user, keyword_type_flag).each do |k, v|
            next unless k.match(/^keyword_search/)
            key_results[k] = keyword_index & v # sort
          end
        end
      end

      # Record failed searches assume they meant to find user_keywords and exempt those keyword failures but do not count them as successes
      if keyword_results && @keywords
        search = Search.create(term: @keywords[0], user_id: current_user.id)
        search.save
      else
        unless user_keyword_results  #### assume they knew to search for their own stuff
          failed = FailedSearch.create(term: @keywords[0], user_id: current_user.id)
          failed.save
        end
      end

    end
    if @my_library
      key_results['my_library:all'] = []
      my_documents = current_user.ac_session_histories.available
      @unique_keys = []
      ac_creator_templates = []
      templates_to_sessions = {}
      my_documents.each do |d|
        next unless access_level_results.include?(['AcCreatorTemplate', d.ac_creator_template.id]) || current_user.superuser?
        access_level_results.push ['UserSavedAds', d.id]
        key_results['my_library:all'].push ['UserSavedAds', d.id]
        ac_creator_templates.push ['AcCreatorTemplate', d.ac_creator_template.id]
        templates_to_sessions[d.ac_creator_template.id.to_i] = [] unless templates_to_sessions[d.ac_creator_template.id.to_i]
        templates_to_sessions[d.ac_creator_template.id.to_i].push d.id.to_i
        # setup match sequence between UserSavedAds and AcCreatorTemplates
      end

      # need to replace topic and media_type results with expanded usersaveds ads
      key_results.each do |k, asset_keys|
        user_saved_ads = []
        next unless /^(topic|media_type|keyword:)/.match(k)
        # logger.debug "match key: " + k.to_s
        asset_keys.each do |_asset_type, asset_id|
          next unless templates_to_sessions[asset_id]
          templates_to_sessions[asset_id].each do |user_saved_ad_id|
            logger.debug 'found sessions for topic: ' + k.to_s + ' - ' + user_saved_ad_id.to_s
            user_saved_ads.push ['UserSavedAds', user_saved_ad_id]
          end
        end
        # replace key_results
        key_results[k] = user_saved_ads
      end
    end

    ##### Merge results

    # put exact match in front of result set
    @unique_keys = []
    if @phrase_match_results.present?
      @phrase_match_results.each do |_k, v|
        @unique_keys = keyword_index & v # sort
        break
      end
    end

    # what to do with key_results?
    # iterate over them and merge to determine intersection criteria
    search_keys = []
    logger.debug '@unique_keys (' + @keywords.inspect + ') ' + @unique_keys.inspect
    if key_results
      counter = nil
      key_results.each do |k, v|
        logger.debug 'k: ' + k.to_s
        next if k =~ /^keyword:/ || k =~ /^user_keyword:/
        sorted_v = @my_library ? v : keyword_index & v
        search_keys.push k
        if counter
          @unique_keys &= sorted_v
        else
          @unique_keys = sorted_v.uniq
        end
        logger.debug '@unique_keys (' + k + ') ' + @unique_keys.inspect
        counter = 1
      end
    end

    # restrictable
    @unique_keys &= access_level_results if @access_levels.count > 0 && !current_user.superuser? || (current_user.superuser? && @search_access_levels.present?)
    # exclude group_only images unless group_only_flag
    unless params[:group_only_flag]
      if @my_contributions == ['my-contributions']
        bundle_only_images = DlImage.where(group_only_flag: true).where.not(user_id: current_user.id).pluck(:id).map! { |id| ['DlImage', id] }
      else
        bundle_only_images = DlImage.where(group_only_flag: true).pluck(:id).map! { |id| ['DlImage', id] }
      end
      @unique_keys -= bundle_only_images
    end

    @results_count = @unique_keys.length

    if (!@keywords.present? || @keywords == ['']) && (@my_library || @my_contributions || @ac_images)
      @unique_keys = @unique_keys.reverse.first(MAX_RESULTS)
    else
      @unique_keys = @unique_keys.first(MAX_RESULTS)
    end
    @max_results = MAX_RESULTS

    render partial: 'search', content_type: 'text/html'
  end

  private

  def keyword_search(keyword, current_user, keyword_type_flag)
    # minimum 2 characters
    return {} unless keyword.strip.length > 1
    keyword_param = '%' + keyword.strip.downcase + '%'
    keyword_types = Keyword.keyword_types('keyword', keyword_type_flag)
    user_keyword_types = %w(keyword category system)
    negation = nil
    negation = (/^!(.*)$/.match(keyword))[1] if /^!(.*)$/.match(keyword)
    keyword_param = '%' + negation.strip.downcase + '%' if negation.present?

    keyword_results = Keyword.where(keyword_type: keyword_types).where('term like ?', keyword_param)

    user_keyword_results = UserKeyword.where(user_id: current_user.id).where(user_keyword_type: user_keyword_types).where('term like ?', keyword_param)

    key_results = {}

    if keyword_results.count > 0 || user_keyword_results.count > 0
      if keyword_results.count > 0
        if negation.present?
          key_results['keyword:' + keyword] =  Keyword.where(keyword_type: keyword_types).pluck('distinct searchable_type, searchable_id') - keyword_results.pluck('distinct searchable_type, searchable_id')
        else
          key_results['keyword:' + keyword] = keyword_results.pluck('distinct searchable_type, searchable_id')
        end
      end
      if user_keyword_results.count > 0
        if negation.present?
          key_results['user_keyword:' + keyword] =   UserKeyword.where(user_id: current_user.id).where(user_keyword_type: user_keyword_types).pluck('distinct categorizable_type, categorizable_id') - user_keyword_results.pluck('distinct categorizable_type, categorizable_id')
        else
          key_results['user_keyword:' + keyword] = user_keyword_results.pluck('distinct categorizable_type, categorizable_id')
        end
      end
      key_results['keyword_search:' + keyword] = key_results['keyword:' + keyword] if key_results['keyword:' + keyword].present?
      key_results['keyword_search:' + keyword] = key_results['keyword_search:' + keyword] + key_results['user_keyword:' + keyword] if key_results['keyword_search:' + keyword].present? && key_results['user_keyword:' + keyword].present?
    else
      if negation.present?
        key_results['keyword_search:' + keyword] = Keyword.all.pluck('distinct searchable_type, searchable_id')
      else
        key_results['keyword_search:' + keyword] = []
      end
    end

    ### hook to extend results for kwikee_product upc search for keywords of length 5, 6, 10, 12, 13, 14
    if [5, 6, 10, 12, 13, 14].include?(keyword.strip.length)
      kwikee_upc_results = KwikeeProduct.where('gtin like ?', keyword_param).pluck(:id)
      kwikee_upc_results.each do |id|
        key_results['keyword_search:' + keyword] << [KwikeeProduct.name, id]
      end
    end
    key_results
  end

  def admin_keyword_helper
    @keywordable_type = params[:keywordable_type]
    @token = params[:token]

    language = params[:language] || params[:previous_language]
    access_level = params[:access_level] || params[:previous_access_level]

    @admin_active_panel_style = {}
    %w(add edit advanced).each do |panel|
      @admin_active_panel_style[panel] = { 'display' => 'none', 'active' => '' }
    end
    case params[:admin_active_panel]
    when 'edit'
      @admin_active_panel_style['edit'] = { 'display' => 'block', 'active' => 'active' }
    when 'advanced'
      @admin_active_panel_style['advanced'] = { 'display' => 'block', 'active' => 'active' }
    else
      @admin_active_panel_style['add'] = { 'display' => 'block', 'active' => 'active' }
    end

    @fulfillment_methods = FulfillmentMethod.all
    @real_user = real_user

    @access_levels = current_user.admin_permissions
    access_level = @access_levels.first.id.to_s if @access_levels.count == 1
    @languages = Language.all
    language = @languages.first.id.to_s if @languages.count == 1

    if language.present?
      @language = Language.find(language)
      @language_id = @language.id
    end
    if access_level.present?
      access_level = access_level.gsub(/\s+/, '')
      access_level_array = access_level.split(',') - ['', ' ', nil]
      everyone_id = AccessLevel.where(name: 'everyone').pluck(:id)[0]
      access_level = [access_level, everyone_id]
      @access_level = AccessLevel.find(access_level_array.first)
      @access_level_id = @access_level.id
    end

    @top_level_categories = {}
    @top_level_categories_select = {}

    @filter_criteria_met = false
    access_language_accessible = KeywordTerm.where(parent_term_id: nil)
    if @access_levels.count > 0
      if access_level.present?
        if @languages.count > 0
          if language.present?
            access_language_accessible = access_language_accessible.where(language_id: language, access_level_id: access_level)
            @filter_criteria_met = true
          end
        else
          access_language_accessible = access_language_accessible.where(language_id: nil, access_level_id: access_level)
          @filter_criteria_met = true
        end
      end
    else
      if @languages.count > 0
        if language.present?
          access_language_accessible = access_language_accessible.where(language_id: language, access_level_id: nil)
          @filter_criteria_met = true
        end
      else
        access_language_accessible = access_language_accessible.where(language_id: nil, access_level_id: nil)
        @filter_criteria_met = true
      end
    end

    @top_level_categories = {}
    @top_level_categories_select = {}
    search = KeywordType.where(name: 'search').first
    @keyword_types = [search]
    @keyword_labels = { 'search' => search.label }
    @keyword_strings = { 'search' => [] }
    if @filter_criteria_met
      keyword_types = KeywordType.categories.order(:name)
      keyword_types.each do |keyword_type|
        @keyword_labels[keyword_type.name] = keyword_type.label
        @keyword_strings[keyword_type.name] = []
        next if keyword_type == 'search'
        next if keyword_type.name == 'ac_image_filter' && !@real_user.superuser?
        @keyword_types << keyword_type
        @top_level_categories[keyword_type.name] = access_language_accessible.where(keyword_type: keyword_type.name).order(:access_level_id, :term)
        @top_level_categories_select[keyword_type.name] = [['Select Parent ' + keyword_type.label.to_s, '']] + @top_level_categories[keyword_type.name].pluck(:term, :id)
      end
    end
    @all_top_level_categories = {}
    @all_keyword_types = [search]
    @all_keyword_strings = { 'search' => [] }
    keyword_types = KeywordType.categories.order(:name)
    keyword_types.each do |keyword_type|
      @all_keyword_strings[keyword_type.name] = []
      next if keyword_type == 'search'
      next if keyword_type.name == 'ac_image_filter' && !@real_user.superuser?
      @all_keyword_types << keyword_type
      @all_top_level_categories[keyword_type.name] = KeywordTerm.where(keyword_type: keyword_type.name, parent_term_id: nil, access_level_id: @access_levels.pluck(:id)).order(:access_level_id, :term)
    end

    ungrouped_images = []
    @group_objs = []
    if @keywordable_type.present? && @token.present?
      # single op support
      @current_keyword_group = { @keywordable_type => { @token => 'active' } }
    else
      @current_keyword_group = current_asset_group
    end
    logger.debug @current_keyword_group

    @current_keyword_group.each do |keywordable_type, tokens|
      # filter out user content potentially in asset_group
      next if keywordable_type == 'UserUploadedImage'
      next if keywordable_type == 'UserSavedAds'
      next if keywordable_type == 'KwikeeAsset'
      tokens.each do |token, _v|
        asset = LoadAsset.load_asset(type: keywordable_type, token: token)
        if keywordable_type == 'DlImageGroup'

          child_images = []
          if current_user.superuser?
            dl_images = asset.dl_images
          else
            dl_images = asset.dl_images.user_permitted(current_user.id)
          end

          dl_images.each do |child_image|
            next unless asset.user_id == current_user.id && current_user.contributor? || current_user.admin? || current_user.superuser?
            asset_obj = { key: child_image.class.name + '|' + token.to_s, asset: child_image }
            @all_keyword_types.each do |keyword_type|
              asset_obj[keyword_type.name] = child_image.keywords.where(keyword_type: child_image.keyword_prefix + keyword_type.name).pluck(:term)
              @all_keyword_strings[keyword_type.name].push asset_obj[keyword_type.name]
            end
            child_images.push asset_obj
          end
          image_group = { key: keywordable_type + '|' + token.to_s, assets: child_images, asset: asset }
          @group_objs.push image_group

        else
          ### restict by user unless  collaborator? and user_id match || admin?, superuser?
          next unless (!%w(KwikeeProduct).include?(asset.class.name) && asset.user_id == current_user.id && current_user.contributor?) || current_user.admin? || current_user.superuser?
          asset_obj = { key: keywordable_type.to_s + '|' + token.to_s, asset: asset }

          @all_keyword_types.each do |keyword_type|
            asset_obj[keyword_type.name] = asset.keywords.where(keyword_type: asset.keyword_prefix + keyword_type.name).pluck(:term)
            @all_keyword_strings[keyword_type.name].push asset_obj[keyword_type.name]
          end
          ungrouped_images.push asset_obj
        end
      end
    end
    ungrouped_images_obj = { key: 'ungrouped', assets: ungrouped_images, asset: nil }
    @group_objs.push ungrouped_images_obj
  end
end
