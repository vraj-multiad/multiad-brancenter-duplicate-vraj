# == Schema Information
#
# Table name: ac_creator_templates
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  title                    :string(255)
#  bundle                   :string(255)
#  preview                  :string(255)
#  thumbnail                :string(255)
#  document_spec_xml        :text
#  created_at               :datetime
#  updated_at               :datetime
#  ac_base_id               :integer
#  filename                 :string(255)
#  folder                   :string(255)
#  expired                  :boolean          default(FALSE)
#  status                   :string(255)      default("inprocess")
#  token                    :string(255)
#  user_id                  :integer
#  description              :text
#  publish_at               :datetime
#  unpublish_at             :datetime
#  ac_creator_template_type :string(255)
#

# class AcCreatorTemplate < ActiveRecord::Base
class AcCreatorTemplate < ActiveRecord::Base
  belongs_to :user
  belongs_to :ac_base
  has_and_belongs_to_many :keywords
  has_many :ac_sessions
  has_many :ac_session_histories, through: :ac_sessions
  has_and_belongs_to_many :user_keywords
  has_many :user_keywords, as: :categorizable
  has_many :keywords, as: :searchable
  has_one :keyword_index, as: :indexable, dependent: :delete
  has_many :set_attributes, as: :setable, dependent: :delete_all
  has_many :responds_to_attributes, as: :respondable, dependent: :delete_all
  has_and_belongs_to_many :asset_access_levels
  has_many :asset_access_levels, as: :restrictable
  has_many :fulfillment_items, as: :fulfillable
  has_many :order_items, as: :orderable
  has_many :operation_queues, as: :operable
  has_and_belongs_to_many :ac_creator_template_groups, join_table: :ac_creator_template_groups_ac_creator_templates
  mount_uploader :bundle, BundleUploader

  scope :sub_templates, -> { where("#{table_name}.expired = ? and ac_creator_template_type is not null and ac_creator_template_type != ''", false) }
  scope :incomplete, -> { where("#{table_name}.status not in ('unpublished','unstaged','processed','pre-publish','complete','production')") }
  scope :available, -> { where("#{table_name}.status not in ('unpublished','unstaged','processed','complete')") }

  include LineParser
  include Tokenable
  include Respondable
  include Setable
  include Indexable
  include Keywordable
  include Publishable

  def expire!
    pub_expire
    save!
  end

  def favorite?(user_id)
    user_keywords.where(user_id: user_id, title: 'Favorites', term: 'favorites').count > 0
  end

  def downloadable?
    false
  end

  def image_uploader
    bundle
  end

  def asset_type
    self.class.name
  end

  def shareable?
    false
  end

  def image?
    true
  end

  def audio?
    false
  end

  def video?
    false
  end

  def upload_type
    'creator_template'
  end

  def bundle_url
    SECURE_BASE_URL + '/creator_templates/' + APP_ID + '/' + id.to_s + '/content/' + id.to_s + '.zip'
  end

  def thumbnail_url
    SECURE_BASE_URL + thumbnail.to_s
  end

  def preview_url
    # SECURE_BASE_URL + preview
    #### fixed up
    if preview.present? && preview != '/creator_templates/' + APP_ID + '/' + id.to_s + '/preview_' + id.to_s + '_'
      self.preview = '/creator_templates/' + APP_ID + '/' + id.to_s + '/preview_' + id.to_s + '_'
      self.save!
    end
    SECURE_BASE_URL + preview.to_s + '1.png'
  end

  def cart_files
    []
  end

  def specs
    JSON.parse(document_spec_xml)
  end

  def element_coordinates
    element_coordinates = {}
    unless /<\/HTML>$/.match(document_spec_xml)
      doc_xml = JSON.parse(document_spec_xml)

      doc_coord = { 'height' => doc_xml['size']['height'].to_f, 'width' => doc_xml['size']['width'].to_f }
      element_coordinates['doc_specs'] = doc_coord

      ac_base.ac_steps.each do |ac_step|
        element_name = ac_step.form_data('element_name')
        # ac_step_type = ac_step.form_data('ac_step_type')
        coordinates = {}
        next unless doc_xml['elements'].present?
        doc_xml['elements'].each do |_k, e|
          logger.debug e.inspect
          logger.debug e['name'].to_s
          logger.debug element_name.to_s
          next unless e['name'].to_s == element_name
          coordinates['top'] = e['top'].to_f
          coordinates['left'] = e['left'].to_f
          coordinates['bottom'] = e['bottom'].to_f
          coordinates['right'] = e['right'].to_f

          coordinates['height'] = e['bottom'].to_f - e['top'].to_f
          coordinates['width'] = e['right'].to_f - e['left'].to_f

          offset = 4.to_f
          coordinates['top_percent'] = (100 * (e['top'].to_f - offset) / (doc_xml['size']['height'].to_f)).round(2)
          coordinates['left_percent'] = (100 * (e['left'].to_f - offset) / (doc_xml['size']['width'].to_f)).round(2)

          coordinates['height_percent'] = (100 * (coordinates['height'].to_f + (2 * offset)) / (doc_xml['size']['height'].to_f)).round(2)
          coordinates['width_percent'] = (100 * (coordinates['width'].to_f + (2 * offset)) / (doc_xml['size']['width'].to_f)).round(2)
          logger.debug e['name'].to_s
          logger.debug coordinates.inspect

          label_size = 20
          pos = 5

          coordinates['label_width'] = label_size / coordinates['width'] * 100
          coordinates['label_height'] = label_size / coordinates['height'] * 100

          coordinates['label_top'] =  -pos
          coordinates['label_left'] = -pos
        end
        element_coordinates[element_name] = coordinates
      end
    end
    element_coordinates
  end
end
