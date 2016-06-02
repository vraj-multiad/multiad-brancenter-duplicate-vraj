# == Schema Information
#
# Table name: ac_texts
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  title            :string(255)
#  creator          :text
#  html             :text
#  created_at       :datetime
#  updated_at       :datetime
#  expired          :boolean          default(FALSE)
#  status           :string(255)      default("inprocess")
#  token            :string(255)
#  user_id          :integer
#  inputs           :text
#  contact_flag     :boolean          default(FALSE)
#  contact_type     :string(255)
#  contact_filter   :string(255)
#  publish_at       :datetime
#  unpublish_at     :datetime
#  properties       :hstore
#  ac_text_type     :string(255)      default("")
#  ac_text_sub_type :string(255)      default("")
#  unique_key       :string(255)
#

class AcText < ActiveRecord::Base
  include LineParser
  include Respondable
  include Setable
  include Tokenable
  include Indexable
  include Keywordable
  include Publishable
  store_accessor :properties

  default_scope { order(name: :asc) }

  after_create :set_everyone_access_level
  after_save :reset_system_keywords
  belongs_to :user
  has_and_belongs_to_many :keywords
  has_many :keywords, as: :searchable
  has_one :keyword_index, as: :indexable, dependent: :delete
  has_many :set_attributes, as: :setable, dependent: :delete_all
  has_many :responds_to_attributes, as: :respondable, dependent: :delete_all
  has_and_belongs_to_many :asset_access_levels
  has_many :asset_access_levels, as: :restrictable
  has_many :operation_queues, as: :operable

  def expire!
    pub_expire
    save!
  end

  def update_keywords(keyword_param)
    keywords.where(keyword_type: 'search').destroy_all
    keywords_array = keyword_param.split(',') - ['', ' ', nil]
    keywords_array = keywords_array.map(&:strip)
    keywords_array = keywords_array.map(&:downcase)
    keywords_array = keywords_array.uniq
    keywords_array.each do |k|
      keywords.create(keyword_type: 'search', term: k)
    end
  end

  def parsed_inputs
    return {} unless inputs.present?
    line_parser_input_line 'input', input_line
  end

  def input_line
    inputs.gsub(/^input=/, '')
  end

  def html_display
    html_text = html
    parsed_inputs.each do |input|
      input_var = '__' + input['name'] + '__'
      input_val = '[' + input['title'] + ']'
      html_text.gsub!(/#{Regexp.escape(input_var)}/, input_val)
    end
    html_text
  end

  private

  def set_everyone_access_level
    everyone_access_level = AccessLevel.find_by(name: 'everyone')
    asset_access_levels.create(access_level_id: everyone_access_level.id) if everyone_access_level.present?
  end

  def reset_system_keywords
    keywords.where(keyword_type: 'system').destroy_all
    keywords.create(keyword_type: 'system', term: creator.downcase) if creator.present?
    keywords.create(keyword_type: 'system', term: html.downcase) if html.present?
  end
end
