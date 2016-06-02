# == Schema Information
#
# Table name: keyword_terms
#
#  id              :integer          not null, primary key
#  term            :string(255)
#  parent_term_id  :integer
#  keyword_type    :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  term_count      :integer
#  language_id     :integer
#  access_level_id :integer
#

# class KeywordTerm < ActiveRecord::Base
class KeywordTerm < ActiveRecord::Base
  scope :active, -> { where 'term_count > 0' }
  scope :top_level_topics, -> { where keyword_type: 'topic', parent_term_id: nil }
  scope :topic, -> { where keyword_type: 'topic' }
  scope :top_level_media_types, -> { where keyword_type: 'media_type', parent_term_id: nil }
  scope :media_type, -> { where keyword_type: 'media_type' }
  scope :ac_image_filter, -> { where keyword_type: 'ac_image_filter' }

  has_many :sub_terms, class_name: 'KeywordTerm', foreign_key: 'parent_term_id'
  belongs_to :parent_term, class_name: 'KeywordTerm', foreign_key: 'parent_term_id'
  belongs_to :language

  def permitted_sub_terms(permission_ids)
    parent_terms = KeywordTerm.where(term: term, keyword_type: keyword_type, access_level_id: permission_ids)
    if parent_terms.count > 0
      KeywordTerm.where(parent_term_id: parent_terms.pluck(:id)).order(:term)
    else
      sub_terms
    end
  end
end
