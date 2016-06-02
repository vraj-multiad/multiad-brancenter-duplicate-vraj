# == Schema Information
#
# Table name: kwikee_products
#
#  id                          :integer          not null, primary key
#  allergens                   :text
#  brand_id                    :integer
#  brand_name                  :text
#  case_count                  :text
#  case_depth                  :text
#  case_gtin                   :text
#  case_height                 :text
#  case_width                  :text
#  category                    :text
#  column_heading              :text
#  column_headings             :text
#  component_element           :text
#  component_elements          :text
#  consumable                  :text
#  container_type              :text
#  custom_product_name         :text
#  department                  :text
#  depth                       :text
#  description                 :text
#  diabetes_fc_values          :text
#  disease_claim               :text
#  display_depth               :text
#  display_height              :text
#  display_width               :text
#  division_name               :text
#  division_name_2             :text
#  extra_text_2                :text
#  extra_text_3                :text
#  extra_text_4                :text
#  fat_free                    :text
#  flavor                      :text
#  footer                      :text
#  footers                     :text
#  footnote                    :text
#  footnotes                   :text
#  format                      :text
#  gluten_free                 :text
#  gpc_attributes_assigned     :datetime
#  gpc_brick_id                :integer
#  gpc_brick_name              :text
#  gpc_class_id                :integer
#  gpc_class_name              :text
#  gpc_family_id               :integer
#  gpc_family_name             :text
#  gpc_segment_id              :integer
#  gpc_segment_name            :text
#  gtin                        :text
#  guarantee_analysis          :text
#  guarantees                  :text
#  header                      :text
#  headers                     :text
#  height                      :text
#  image_indicator             :text
#  indications_copy            :text
#  ingredient_code             :text
#  ingredients                 :text
#  instruction_copy_1          :text
#  instruction_copy_2          :text
#  instruction_copy_3          :text
#  instruction_copy_4          :text
#  instruction_copy_5          :text
#  interactions_copy           :text
#  is_variant_flag             :text
#  kosher                      :text
#  kwikee_why_buy              :text
#  last_publish_date           :datetime
#  legal                       :text
#  low_fat                     :text
#  manufacturer_id             :integer
#  manufacturer_name           :text
#  mfr_approved_date           :datetime
#  model                       :text
#  multiple_shelf_facings      :text
#  name                        :text
#  nutrient_claim_1            :text
#  nutrient_claim_2            :text
#  nutrient_claim_3            :text
#  nutrient_claim_4            :text
#  nutrient_claim_5            :text
#  nutrient_claim_6            :text
#  nutrient_claim_7            :text
#  nutrient_claim_8            :text
#  nutrition_footnotes_1       :text
#  nutrition_footnotes_2       :text
#  nutrition_head_1            :text
#  nutrition_head_2            :text
#  organic                     :text
#  other_nutrient_statement    :text
#  override_manufacturer_tasks :text
#  peg_down                    :text
#  peg_right                   :text
#  physical_weight_lb          :text
#  physical_weight_oz          :text
#  post_consumer               :text
#  primary_gtin                :text
#  primary_type                :text
#  primary_version             :text
#  product_count               :text
#  product_form                :text
#  product_id                  :integer
#  product_name                :text
#  product_size                :text
#  product_type                :text
#  profile_id                  :text
#  promotion                   :text
#  romance_copy_1              :text
#  romance_copy_2              :text
#  romance_copy_3              :text
#  romance_copy_4              :text
#  romance_copy_category       :text
#  section_id                  :text
#  section_name                :text
#  segment                     :text
#  segments                    :text
#  sensible_solutions          :text
#  size_description_1          :text
#  size_description_2          :text
#  ss_claim_1                  :text
#  ss_claim_2                  :text
#  ss_claim_3                  :text
#  ss_claim_4                  :text
#  supplemental_facts          :text
#  tray_count                  :text
#  tray_depth                  :text
#  tray_height                 :text
#  tray_width                  :text
#  unit_container              :text
#  unit_size                   :text
#  unit_uom                    :text
#  uom                         :text
#  upc_10                      :text
#  upc_12                      :text
#  value                       :text
#  values                      :text
#  variant_name_1              :text
#  variant_name_2              :text
#  variant_value_1             :text
#  variant_value_2             :text
#  vm_claim_1                  :text
#  vm_claim_2                  :text
#  vm_claim_3                  :text
#  vm_claim_4                  :text
#  vm_type_1                   :text
#  vm_type_2                   :text
#  vm_type_3                   :text
#  vm_type_4                   :text
#  warnings_copy               :text
#  width                       :text
#  created_at                  :datetime
#  updated_at                  :datetime
#  token                       :string(255)
#  why_buy_1                   :text
#  why_buy_2                   :text
#  why_buy_3                   :text
#  why_buy_4                   :text
#  why_buy_5                   :text
#  why_buy_6                   :text
#  why_buy_7                   :text
#  default_kwikee_asset_id     :integer
#  default_kwikee_file_id      :integer
#

class KwikeeProduct < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include Indexable
  include Keywordable
  include Tokenable
  include Respondable
  include Setable
  include DefaultImageHelper

  has_many :kwikee_custom_data, dependent: :destroy
  has_many :kwikee_external_codes, dependent: :delete_all
  has_many :kwikee_nutritions, dependent: :delete_all
  has_many :kwikee_assets, dependent: :delete_all
  has_many :kwikee_files, dependent: :delete_all
  has_and_belongs_to_many :keywords
  has_many :keywords, as: :searchable, dependent: :delete_all
  has_one :keyword_index, as: :indexable, dependent: :delete
  has_and_belongs_to_many :user_keywords
  has_many :user_keywords, as: :categorizable, dependent: :delete_all
  has_and_belongs_to_many :asset_access_levels
  has_many :asset_access_levels, as: :restrictable, dependent: :delete_all
  has_many :set_attributes, as: :setable, dependent: :delete_all
  has_many :responds_to_attributes, as: :respondable, dependent: :delete_all
  # has_and_belongs_to_many :shared_pages
  has_many :shared_page_items, as: :shareable
  has_many :dl_cart_items, as: :downloadable
  has_many :operation_queues, as: :operable

  after_save :rebuild_system_keywords
  after_save :validate_kwikee_access_levels
  after_update :validate_kwikee_access_levels

  def status
    'production'
  end

  def downloadable?
    true
  end

  def expired
    false
  end

  def custom_data
    custom_data = {}
    kwikee_custom_data.includes(:kwikee_custom_data_attributes).each do |kcd|
      kcd.kwikee_custom_data_attributes.each do |kcda|
        custom_data[ kcd.name + '.' + kcda.name ] = kcda.value
      end
    end
    custom_data
  end

  def external_codes
    external_codes = {}
    kwikee_external_codes.each do |kec|
      external_codes[ 'kec.' + kec.name ] = kec.value
    end
    external_codes
  end

  def title
    custom_product_name.to_s
  end

  def shareable?
    true
  end

  def shareable_via_social_media?
    true
  end

  def shareable_via_email?
    true
  end

  def audio?
    false
  end

  def video?
    false
  end

  def image?
    false
  end

  def file?
    false
  end

  def extension
    'zip'
  end

  def upload_type
    'image'
  end

  def favorite?(user_id)
    user_keywords.where(user_id: user_id, title: 'Favorites', term: 'favorites').count > 0
  end

  def rebuild_system_keywords
    keywords.where(keyword_type: 'system').destroy_all
    keywords.where(keyword_type: 'category').destroy_all
    system_keyword_string = manufacturer_name.to_s + ' ' + brand_name.to_s + ' ' + division_name.to_s + ' ' + division_name_2.to_s + ' ' + custom_product_name.to_s + ' ' + created_at.strftime('%m-%d-%Y')
    keywords.create(keyword_type: 'system', term: system_keyword_string.downcase)
    keywords.create(keyword_type: 'category', term: 'asset-library')
  end

  def validate_kwikee_access_levels
    return unless KWIKEE_API_ACCESS_LEVELS
    man_fields = { name: manufacturer_name.downcase.to_s, title: manufacturer_name.to_s, access_level_type: 'kwikee' }
    manufacturer_access_level = AccessLevel.where(man_fields).first_or_create
    brand_fields = { name: brand_name.downcase.to_s, title: brand_name.to_s, access_level_type: 'kwikee', parent_access_level_id: manufacturer_access_level.id }
    brand_access_level = AccessLevel.where(brand_fields).first_or_create
    asset_access_levels.where(access_level_id: manufacturer_access_level.id).first_or_create
    asset_access_levels.where(access_level_id: brand_access_level.id).first_or_create
  end

  def first_available
    default_view_order = %w(
      CL
      CF
      CR
      BL
      BF
      BR
      VR
    )

    all_view_order = %w(
      CF CL CR CS CX CY
      RF RR RL
      UF UR UL
      C0 C1 C2 C3 C4 C5 C6 C8 C9
      CG
      SHELFMAN shelfman
      PV
      VR
      NF
      DF
      IN
      BF BL BR BS BG BX BY
      RB UB
      TF TR TL TS TG TX TY
      B F R L X S C B_ T_ T Y
      XF XL XR
      BC
    )
    sorted_view_order = default_view_order + all_view_order
    default_views = []
    sorted_view_order.each do |view_code|
      default_views.concat kwikee_assets.where(view: view_code)    ###### PROMOTION????  may use different asset result.
      # break if default_views.present?
    end
    chosen_file = nil
    default_views.each do |default_view|
      test_for_files = default_view.kwikee_files.where(extension: %w(GIF gif JPG jpg JPEG jpeg))
      chosen_file = test_for_files.take if test_for_files.present?
      break if chosen_file.present?
    end
    chosen_file
  end

  def secure_url
    default_kwikee_file.secure_url
  end

  def share_url
    default_kwikee_file.share_preview
  end

  def share_preview
    default_kwikee_file.share_preview
  end

  def thumbnail_url
    secure_url
  end

  def rebuild_defaults
    file = first_available
    if file.present?
      self.default_kwikee_file_id = file.id
      self.default_kwikee_asset_id = file.kwikee_asset_id
      save
    else
      destroy
      return "KWIKEE PRODUCT HAS NO VALID IMAGES: #{gtin}\n"
    end
    nil
  end

  def default_kwikee_asset
    KwikeeAsset.find(default_kwikee_asset_id)
  end

  def default_kwikee_file
    KwikeeFile.find(default_kwikee_file_id)
  end

  def default_thumbnail
    default_images
  end

  def default_thumbnail_url
    '/assets/' + default_thumbnail
  end
end
