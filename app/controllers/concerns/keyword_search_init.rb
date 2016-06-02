# module KeywordSearchInit
module KeywordSearchInit
  extend ActiveSupport::Concern

  included do
    def keyword_search_init
      ###
      clear_categorize = params[:clear_categorize]
      if clear_categorize.to_i == 1
        logger.debug 'clear categorize!'
        init_asset_group
      end
      @keywords = params[:keywords]
      @categories = params[:categories] || []
      @search_access_levels = []
      @search_access_levels = params[:search_access_levels] - [''] if params[:search_access_levels].present?
      @search_access_levels = @search_access_levels.map(&:to_i) if @search_access_levels.present?
      @topics = params[:topics]
      @sub_topics = params[:sub_topics]
      @media_types = params[:media_types]
      @sub_media_types = params[:sub_media_types]
      @user_categories = params[:user_categories]
      @search_sort = params[:sort] || DEFAULT_SORT
      @current_cart_items = current_cart_items
      # @current_categorize = current_categorize

      @current_asset_group = current_asset_group
      logger.debug 'current_asset_group.inspect'
      logger.debug current_asset_group.inspect
      @group_results_by_user_category = params[:group_results_by_user_category]

      @my_documents = params[:my_documents]
      @user_content = params[:user_content]
      @my_contributions = params[:my_contributions]
      @ac_images = params[:ac_images]
      @limit = 20_000

      uncategorized = ''
      no_access_levels = false
      # clean up keywords
      if @keywords.present?
        @keywords.each do |keyword|
          keyword.gsub!(/®|©|℠|™/, '')
          keyword.gsub!(/^('|")/, '')
          keyword.gsub!(/('|")$/, '')
        end
      end
      if !(@keywords.nil? || @keywords == ['']) && (/^!!.*!!$/.match(@keywords[0]))
        uncategorized = (/^!!(.*)!!$/.match @keywords[0])[1]
        if uncategorized == 'access_levels'
          uncategorized = ''
          no_access_levels = true
        end
        @keywords = ['']
      end

      num_categories = 0
      @category_label = t '__global__'
      @active_categories = {}
      @checked_categories = {}
      @categories.each do |cat|
        next if cat.empty?
        num_categories += 1
        @active_categories[cat] = 'active'
        @checked_categories[cat] = 'checked'
        @category_label = cat
      end

      case num_categories
      when 0
        ['adcreator', 'user-library', 'asset-library'].each do |cat|
          @active_categories[cat] = 'active'
          @checked_categories[cat] = 'checked=checked'
        end
      when 2
        @category_label = t '__multicategory__'
      when 3
        @category_label = t '__global__'
      end

      @my_library = false
      # logger.debug 'my_documents: ' + @my_documents.inspect
      if @my_documents && @my_documents != ['']
        logger.debug('search_my_documents')
        @categories = []

        @my_library = true
        # return search_my_documents
      end

      @filter_type = 'search'

      # accumulate media types
      @access_levels = current_user.permissions
      language_id = current_language
      languages = Language.where(name: language_id)
      access_language_accessible = KeywordTerm.all
      everyone_id = AccessLevel.where(name: 'everyone').pluck(:id)[0]
      if @search_access_levels.present?
        temp_search_access_levels = @search_access_levels
        temp_search_access_levels << everyone_id unless temp_search_access_levels.include?(everyone_id)
        access_language_accessible = KeywordTerm.where(access_level_id: temp_search_access_levels)
      end
      if @access_levels.count > 0
        if languages.count > 0
          access_language_accessible = access_language_accessible.where(language_id: languages.first.id, access_level_id: @access_levels.pluck(:id))
        else
          access_language_accessible = access_language_accessible.where(language_id: nil, access_level_id: @access_levels.pluck(:id))
        end
      else
        if languages.count > 0
          access_language_accessible = access_language_accessible.where(language_id: languages.first.id)
        else
          access_language_accessible = access_language_accessible.where(language_id: nil)
        end
      end

      @all_media_types = access_language_accessible.active.top_level_media_types.order('term asc')
      @all_topics = access_language_accessible.active.top_level_topics.order('term asc')

      @selected_keyword_term_media_type = nil
      @selected_keyword_term_topic = nil

      @access_level_title = t '__select_access_group__'
      @topic_title = t '__select_topic__'
      @sub_topic_title = t '__select_sub_topic__'
      @media_type_title = t '__select_media_type__'
      @sub_media_type_title = t '__select_sub_media_type__'

      if @access_levels.count > 0 && !current_user.superuser? || (current_user.superuser? && @search_access_levels.present?)
        access_ids = @access_levels.pluck(:id)
        if (@search_access_levels - access_ids).empty?
          if @search_access_levels.length == 0  # is not selected
            @access_level_title = t '__select_access_group__'
          elsif @search_access_levels.length == 1  # is everyone
            @access_level_title = AccessLevel.find(@search_access_levels[0]).title
          elsif @search_access_levels.length == 2 # remove everyone
            access_level_id_without_everyone = @search_access_levels - [everyone_id]
            @access_level_title = AccessLevel.find(access_level_id_without_everyone[0]).title
          else
            @access_level_title = t '__multiple__'
          end
        else
          @search_access_levels = []
        end
      end

      if @topics && @topics != ['']
        # topics are subtractive, but not multi-selectable
        @selected_keyword_term_topic = KeywordTerm.active.where('lower(term) = ? and keyword_type = ? ', @topics[0], 'topic').take
        @topic_title = @selected_keyword_term_topic.term

        # search by sub_term since it is more specific
        if @sub_topics && @sub_topics != ['']
          @selected_keyword_term_sub_topic = KeywordTerm.active.where('lower(term) = ? and keyword_type = ? ', @sub_topics[0], 'topic').take
          @sub_topic_title = @selected_keyword_term_sub_topic.term
        end
      end

      if @media_types && @media_types != ['']
        # media types are subtractive, but not multi-selectable
        @selected_keyword_term_media_type = KeywordTerm.active.where('lower(term) = ? and keyword_type = ? ', @media_types[0], 'media_type').take
        @media_type_title = @selected_keyword_term_media_type.term

        # search by sub_term since it is more specific
        if @sub_media_types && @sub_media_types != ['']
          @selected_keyword_term_sub_media_type = KeywordTerm.active.where('lower(term) = ? and keyword_type = ? ', @sub_media_types[0], 'media_type').take
          @sub_media_type_title = @selected_keyword_term_sub_media_type.term
        end
      end

      return uncategorized, no_access_levels
    end
  end
end
