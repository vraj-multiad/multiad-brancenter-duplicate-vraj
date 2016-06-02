# == Schema Information
#
# Table name: keywords
#
#  id              :integer          not null, primary key
#  term            :text
#  created_at      :datetime
#  updated_at      :datetime
#  searchable_id   :integer
#  searchable_type :string(25)
#  keyword_type    :string(25)
#

class Keyword < ActiveRecord::Base
  scope :category, -> { where keyword_type: 'category' }
  scope :media_type, -> { where keyword_type: 'media_type' }
  scope :topic, -> { where keyword_type: 'topic' }
  scope :search, -> { where keyword_type: 'search' }
  has_many :searches
  has_many :users, through: :searches
  belongs_to :searchable, polymorphic: true

  def self.keyword_types(keyword_type, is_admin = false)
    keyword_types = %w(search system)
    case keyword_type
    when 'search_only'
      keyword_types = %w(search)
      keyword_types += %w(pre-search) if is_admin
      keyword_types += %w(unpublished-search) if is_admin
    when 'keyword'
      keyword_types += %w(ac_image_filter media_type topic)
      keyword_types += %w(pre-ac_image_filter pre-media_type pre-search pre-system pre-topic) if is_admin
      keyword_types += %w(unpublished-ac_image_filter unpublished-media_type unpublished-search unpublished-system unpublished-topic) if is_admin
    when 'topic'
      keyword_types += %w(topic)
      keyword_types += %w(pre-search pre-system pre-topic) if is_admin
      keyword_types += %w(unpublished-search unpublished-system unpublished-topic) if is_admin
    when 'media_type'
      keyword_types += %w(media_type)
      keyword_types += %w(pre-media_type pre-search pre-system) if is_admin
      keyword_types += %w(unpublished-media_type unpublished-search unpublished-system) if is_admin
    when 'ac_image_filter'
      keyword_types += %w(ac_image_filter)
      keyword_types += %w(pre-ac_image_filter pre-search pre-system) if is_admin
      keyword_types += %w(unpublished-ac_image_filter unpublished-search unpublished-system) if is_admin
    when 'category'
      keyword_types = %w(category)
      keyword_types += %w(pre-category) if is_admin
      keyword_types += %w(unpublished-category) if is_admin
    else
      # nothing
      logger.debug 'unsupported keyword_type: ' + keyword_type.to_s
    end
    logger.debug 'keyword_types: ' + keyword_types.to_s
    keyword_types
  end
end
