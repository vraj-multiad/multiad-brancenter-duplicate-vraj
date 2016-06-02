# module KeywordTermsAdmin
module KeywordTermsAdmin
  extend ActiveSupport::Concern

  included do
    def render_admin_keyword_terms(view, parent_term_id, param_language_id, param_access_level_id)
      language = params[:language] || params[:previous_language] || param_language_id
      access_level = params[:access_level] || params[:previous_access_level] || param_access_level_id

      logger.debug 'language: ' + language.to_s
      logger.debug 'access_level: ' + access_level.to_s
      logger.debug 'current_language: ' + current_language.to_s
      @real_user = real_user

      @access_levels = @real_user.admin_permissions
      access_level = @access_levels.first.id.to_s if @access_levels.count == 1
      @languages = Language.all
      language = @languages.first.id.to_s if @languages.count == 1

      if language.present?
        @language = Language.find(language)
        @language_id = @language.id
      end
      if access_level.present?
        @access_level = AccessLevel.find(access_level)
        @access_level_id = @access_level.id
      end

      @parent_term_id = parent_term_id
      logger.debug '@parent_term_id = ' + parent_term_id.to_s
      @top_level_categories = {}
      @top_level_categories_select = {}
      @keyword_types = []

      filter_criteria_met = false
      access_language_accessible = KeywordTerm.where(parent_term_id: nil)
      if @access_levels.count > 0
        if access_level.present?
          if @languages.count > 0
            if language.present?
              access_language_accessible = access_language_accessible.where(language_id: language, access_level_id: access_level)
              filter_criteria_met = true
            end
          else
            access_language_accessible = access_language_accessible.where(language_id: nil, access_level_id: access_level)
            filter_criteria_met = true
          end
        end
      else
        if @languages.count > 0
          if language.present?
            access_language_accessible = access_language_accessible.where(language_id: language, access_level_id: nil)
            filter_criteria_met = true
          end
        else
          access_language_accessible = access_language_accessible.where(language_id: nil, access_level_id: nil)
          filter_criteria_met = true
        end
      end

      @parent_term_id = parent_term_id
      logger.debug '@parent_term_id = ' + parent_term_id.to_s
      @top_level_categories = {}
      @top_level_categories_select = {}
      @keyword_types = []
      if filter_criteria_met
        keyword_types = KeywordType.categories.order(:name)
        keyword_types.each do |keyword_type|
          next if keyword_type.name == 'ac_image_filter' && !@real_user.superuser?
          @keyword_types << keyword_type
          @top_level_categories[keyword_type.name] = access_language_accessible.where(keyword_type: keyword_type.name).order(:term)
          keyword_term_select = @top_level_categories[keyword_type.name].pluck(:term, :id)
          @top_level_categories_select[keyword_type.name] = [['Select Parent ' + keyword_type.label.to_s, '']] + keyword_term_select
        end
      end
      case view
      when 'keyword_terms'
        render partial: view + '/admin'
      when 'static_pages'
        render view + '/admin'
      end
    end

  end
end
