# == Schema Information
#
# Table name: keyword_indices
#
#  id             :integer          not null, primary key
#  indexable_type :string(255)
#  indexable_id   :integer
#  name           :string(255)      default("")
#  title          :string(255)      default("")
#  date           :datetime
#  custom_1       :string(255)      default("")
#  created_at     :datetime
#  updated_at     :datetime
#  custom_2       :string(255)      default("")
#

class KeywordIndex < ActiveRecord::Base
  belongs_to :indexable, polymorphic: true
  before_create :set_default_date_to_now

  scope :name_asc, -> { order(name: :asc, date: :asc) }
  scope :name_desc, -> { order(name: :desc, date: :desc) }
  scope :title_asc, -> { order(title: :asc, date: :asc) }
  scope :title_desc, -> { order(title: :desc, date: :desc) }
  scope :date_asc, -> { order(date: :asc, title: :asc) }
  scope :date_desc, -> { order(date: :desc, title: :desc) }
  scope :custom_1_asc, -> { order(custom_1: :asc, title: :asc) }
  scope :custom_1_desc, -> { order(custom_1: :desc, title: :desc) }
  scope :custom_2_asc, -> { order(custom_2: :asc, title: :asc) }
  scope :custom_2_desc, -> { order(custom_2: :desc, title: :desc) }
  # Kwikee scopes
  # Manufacturer -> Brand -> gtin
  scope :manufacturer, -> { order(custom_1: :asc, custom_2: :asc, name: :asc) }
  # Brand -> gtin
  scope :brand, -> { order(custom_2: :asc, name: :asc) }

  def self.get_index(sort)
    # Pure Kwikee should probably use manufacturer for default
    sort = DEFAULT_SORT unless sort.present?
    # sort is intended to be the named scope corresponding to the requested value, however should work as a method
    return send(sort).pluck(:indexable_type, :indexable_id) if respond_to?(sort)
  end

  def set_default_date_to_now
    self.date ||= Time.zone.now
  end
  ########################################################################################
  #
  # Custom sort routines would go after this block.
  #
  ########################################################################################
end
