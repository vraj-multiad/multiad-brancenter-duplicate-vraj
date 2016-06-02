module Keywordable
  extend ActiveSupport::Concern

  included do
    def keyword_prefix
      prefix = ''
      case status
      when 'staged', 'processed', 'pre-publish'
        prefix = 'pre-'
      when 'unstaged', 'complete', 'unpublished'
        prefix = 'unpublished-'
      end
      prefix
    end

    def add_default_keywords
      # collect keywords for processing
      keywords = {}
      type_prefix = keyword_prefix

      ## add category
      keywords[type_prefix + 'category'] = default_category_keywords if respond_to? :default_category_keywords

      # append default keywords
      keywords[type_prefix + 'system'] = [name.downcase, title.downcase]

      keywords.each do |keyword_type, keywords_array|
        keywords_array.uniq.each do |k|
          k = k.strip
          keyword_hash = { searchable: self, keyword_type: keyword_type }
          keyword_hash['term'] = k.downcase
          k = Keyword.new(keyword_hash)
          k.save!
        end
      end
    end
  end
end
