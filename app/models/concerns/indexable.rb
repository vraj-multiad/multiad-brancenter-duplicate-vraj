module Indexable
  extend ActiveSupport::Concern

  included do
    after_save :index_asset
    def index_asset
      keyword_index.destroy if keyword_index.present?

      # Skip expired assets note: KwikeeProducts don't repond to expired?
      return if respond_to?(:expired?) && expired?

      case self.class.name
      when 'KwikeeProduct'
        self.keyword_index = KeywordIndex.find_or_create_by(name: gtin.to_s.downcase, title: title.to_s.downcase, date: last_publish_date, custom_1: manufacturer_name.to_s.downcase, custom_2: brand_name.to_s.downcase)
      when 'UserUploadedImage'
        ### TODO: Develop a better mapping of custom_1 and custom_2 to support mixed mode searchs
        self.keyword_index = KeywordIndex.find_or_create_by(name: title.to_s.downcase, title: title.to_s.downcase, date: created_at, custom_1: title.to_s.downcase, custom_2: title.to_s.downcase) if indexable?
      else
        ### TODO: Develop a better mapping of custom_1 and custom_2 to support mixed mode searchs
        self.keyword_index = KeywordIndex.find_or_create_by(name: name.to_s.downcase, title: title.to_s.downcase, date: created_at, custom_1: title.to_s.downcase, custom_2: title.to_s.downcase)
      end
    end
  end
end
