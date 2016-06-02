# == Schema Information
#
# Table name: dl_images
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  title                         :string(255)
#  location                      :string(255)
#  preview                       :string(255)
#  thumbnail                     :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  filename                      :string(255)
#  folder                        :string(255)
#  token                         :string(255)
#  status                        :string(255)      default("inprocess")
#  expired                       :boolean          default(FALSE)
#  bundle                        :string(255)
#  is_shareable                  :boolean          default(TRUE)
#  user_id                       :integer
#  job_id                        :string(255)
#  s3_key                        :string(255)
#  uploaded                      :boolean
#  upload_type                   :string(255)
#  is_shareable_via_social_media :boolean          default(TRUE)
#  is_shareable_via_email        :boolean          default(TRUE)
#  processed_types               :text
#  s3_poll_count                 :integer          default(0)
#  is_downloadable               :boolean          default(TRUE)
#  description                   :text
#  group_only_flag               :boolean          default(FALSE)
#  external_link                 :string(255)
#  external_link_label           :string(255)
#  publish_at                    :datetime
#  unpublish_at                  :datetime
#

# class DlImage < ActiveRecord::Base
class DlImage < ActiveRecord::Base
  around_save :around_save_hook
  after_save :update_dl_image_groups
  include Rails.application.routes.url_helpers
  include Blitlineable
  include Keywordable
  include Publishable
  include Indexable
  include Tokenable
  include Respondable
  include Setable
  include Zencodable
  include DefaultImageHelper

  belongs_to :user
  has_and_belongs_to_many :keywords
  has_many :keywords, as: :searchable
  has_one :keyword_index, as: :indexable, dependent: :delete
  has_and_belongs_to_many :user_keywords
  has_many :user_keywords, as: :categorizable
  has_and_belongs_to_many :asset_access_levels
  has_many :asset_access_levels, as: :restrictable
  has_many :set_attributes, as: :setable, dependent: :delete_all
  has_many :responds_to_attributes, as: :respondable, dependent: :delete_all
  # has_and_belongs_to_many :shared_pages
  has_many :shared_page_items, as: :shareable
  has_many :dl_cart_items, as: :downloadable
  has_many :fulfillment_items, as: :fulfillable
  has_many :order_items, as: :orderable
  has_and_belongs_to_many :dl_image_groups, join_table: :dl_image_groups_dl_images
  has_many :click_events, as: :clickable
  has_many :operation_queues, as: :operable
  has_many :dynamic_form_inputs

  mount_uploader :bundle, BundleUploader
  # @dl_image_group.dl_images.includes(:asset_access_levels).where(asset_access_levels: { access_level_id: current_user.permissions.pluck(:id) })
  scope :available, -> { where(expired: false) }
  scope :complete, -> { where(status: %w(complete staged)) }
  scope :incomplete, -> { where("#{table_name}.status not in ('unpublished','unstaged','processed','pre-publish','complete','production')") }
  scope :downloadable, -> { where(is_downloadable: true) }
  scope :permitted, ->(access_level_ids) { includes(:asset_access_levels).where(asset_access_levels: { access_level_id: access_level_ids }).order('dl_images.title asc') }
  scope :user_permitted, lambda{ |user_id|
    user = User.find(user_id)
    return includes(:asset_access_levels).where(asset_access_levels: { access_level_id: user.permissions.pluck(:id) })
      .where("dl_images.status = 'production' or (dl_images.status in ('pre-publish', 'unpublish') and dl_images.user_id = ?)", user_id)
      .order('dl_images.title asc') if user.user_type == 'user'
    return permitted(user.permissions.pluck(:id)) if user.user_type == 'admin'
    all # superuser
  }

  def downloadable?
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean(is_downloadable)
  end

  def shareable?
    shareable_via_social_media? || shareable_via_email?
  end

  def shareable_via_email?
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean(is_shareable_via_email)
  end

  def shareable_via_social_media?
    ENABLE_SOCIAL_MEDIA && ActiveRecord::ConnectionAdapters::Column.value_to_boolean(is_shareable_via_social_media)
  end

  def update_dl_image_groups
    dl_image_groups.each do |g|
      g.rebuild_searchable
      g.rebuild_restrictable
    end
  end

  before_create :assign_attribute_defaults

  after_create do
    if upload_type == 'file'
      # skip external processing
      dispatch_admin_request
      add_default_keywords
    else
      # setup external processing
      process_upload
    end
  end

  def around_save_hook
    self.is_downloadable = true if is_downloadable.nil?
    self.is_shareable = true if is_shareable.nil?
    self.is_shareable_via_email = true if is_shareable_via_email.nil?
    self.is_shareable_via_social_media = true if is_shareable_via_social_media.nil?
    if external_link.present?
      self.is_downloadable = false
      self.is_shareable = false
      self.is_shareable_via_email = false
      self.is_shareable_via_social_media = false
    end
    yield
  end

  def expire!
    groups = dl_image_groups.pluck(:id)
    dl_image_groups.destroy_all
    groups.each do |g_id|
      g = DlImageGroup.find(g_id)
      g.rebuild_searchable
      g.rebuild_restrictable
    end
    user_keywords.destroy_all
    pub_expire
    save!
  end

  def favorite?(user_id)
    user_keywords.where(user_id: user_id, title: 'Favorites', term: 'favorites').count > 0
  end

  def in_cart?(user_id)
    order_items.joins(:order).merge(Order.active).where('orders.user_id = ?', user_id).count > 0
  end

  def extension
    File.extname(location.to_s)
  end

  def asset_type
    self.class.name
  end

  def shareable_class
    shareable? ? 'shareable' : ''
  end

  def downloadable_class
    'downloadable'
  end

  def categorizable_class
    'categorizable'
  end

  def file?
    if upload_type == 'file'
      true
    else
      false
    end
  end

  def image?
    if upload_type.nil? || upload_type == 'image'
      true
    else
      false
    end
  end

  def audio?
    if upload_type == 'file' && extension == '.mp3'
      true
    else
      false
    end
  end

  def video?
    if upload_type == 'video'
      true
    else
      false
    end
  end

  def share_preview
    if thumbnail.present?
      SECURE_BASE_URL + thumbnail
    elsif self.video? || self.image?  # 'file'
      bundle.thumbnail.url
    else
      thumbnail_url
    end
  end

  def share_url
    if thumbnail.present?
      SECURE_BASE_URL + thumbnail
    else
      if self.video? || self.audio?
        bundle.url
      else
        bundle.thumbnail.url
      end
    end
  end

  def video_preview_url
    bundle.preview.url if self.video?
  end

  def bundle_url
    SECURE_BASE_URL + '/dl_images/' + APP_ID + '/' + id.to_s + '/' + id.to_s + '.zip'
  end

  def thumbnail_url
    if thumbnail.present?
      SECURE_BASE_URL + thumbnail
    elsif self.video?
      bundle.thumbnail.url
    else
      APP_DOMAIN + '/assets/' + default_images(location)
    end
  end

  def preview_url
    #### fixed up
    if preview.present? && preview != '/dl_images/' + APP_ID + '/' + id.to_s + '/preview.png'
      self.preview = '/dl_images/' + APP_ID + '/' + id.to_s + '/preview.png'
      self.save!
    end
    SECURE_BASE_URL + preview if preview.present?
  end

  def cart_files
    @cart_files = []
    if self.video?
      ext = File.extname(bundle.original.path)
      @cart_files << { 'url' => bundle.original.url, 'path' => bundle.original.path, 'unique_name' => token.to_s + ext.downcase }
      @cart_files << { 'url' => bundle.wmv.url, 'path' => bundle.wmv.path, 'unique_name' => token.to_s + '.wmv' } unless ext.downcase == '.wmv'
      @cart_files << { 'url' => bundle.mov.url, 'path' => bundle.mov.path, 'unique_name' => token.to_s + '.mov' } unless ext.downcase == '.mov'
    elsif self.image? && File.extname(location).downcase != '.pdf'
      ext = File.extname(location)
      path = File.dirname(location) + '/'
      @cart_files << { 'location' => path + 'preview.jpg' } unless ext.downcase == '.jpg'
      @cart_files << { 'location' => path + 'preview.png' } unless ext.downcase == '.png'
      @cart_files << { 'location' => location }
    else
      @cart_files << { 'location' => location }
    end
    logger.debug @cart_files
    @cart_files
  end

  def process_upload
    case upload_type
    when 'image'
      create_images
    when 'video'
      create_videos
    else
      logger.debug 'unregistered upload_type: ' + upload_type.to_s
      # need to process direct xml as generic file to stage on MASI with generic preview and thumbnail
    end
  end

  def image_uploader
    bundle
  end

  def admin_xml
    logger.debug 'admin_dl_image_xml id: ' + id.to_s

    data = {}
    data[:app_id] = APP_ID
    data[:image_type] = 'dl_images'
    data[:image_complete_url] = admin_dl_image_staged_url + '?token=' + token.to_s
    if image? || video?
      data[:image_location] = bundle.url
      data[:image_filename] = filename.to_s
      data[:preview_location] = bundle.preview.url
      data[:preview_filename] = bundle.preview.filename.to_s
      data[:thumbnail_location] = bundle.thumbnail.url
      data[:thumbnail_filename] = bundle.thumbnail.filename.to_s
      data[:jpg_location] = bundle.jpg.url
      data[:jpg_filename] = bundle.jpg.filename.to_s
    elsif upload_type == 'file'
      data[:image_location] = bundle.url
      data[:image_filename] = filename.to_s
      data[:image_complete_url] = admin_dl_image_staged_url + '?no_preview=1&token=' + token.to_s
    else
      data[:bundle_location] = bundle.url
      data[:filename] = filename.to_s
    end
    data[:image_id] = id.to_s

    xml = data.to_xml(root: 'dl_image', dasherize: false)
    logger.debug "created admin_xml for dl_image with id #{id} and token #{token}"
    logger.debug xml
    xml
  end

  def dispatch_admin_request
    url = URI.parse("#{ADMIN_URL}/dl_image_#{APP_ID}_#{id}.xml")

    request = Net::HTTP::Put.new(url.path)
    request.body = admin_xml

    response = Net::HTTP.start(url.host, url.port) { |http| http.request(request) }

    logger.debug 'dispatch_dl_image_request'
    logger.debug response.inspect
  end

  def default_category_keywords
    ['asset-library']
  end

  alias_method :original_blitline_complete!, :blitline_complete!
  def blitline_complete!
    return unless status == 'processing'

    original_blitline_complete!
    dispatch_admin_request
    add_default_keywords
  end

  def rebuild_searchable
    dl_image_groups.each(&:rebuild_searchable)
  end

  def rebuild_restrictable
    dl_image_groups.each(&:rebuild_restrictable)
  end

  private

  # TODO: should this go in s3able?
  def assign_attribute_defaults
    basename = File.basename(bundle.key)
    extension = File.extname(bundle.key)
    basename_without_extension = File.basename(bundle.key, extension)

    defaults = {
      filename: basename,
      name: basename_without_extension.downcase,
      s3_key: bundle.key,
      status: 'processing',
      title: basename_without_extension,
      uploaded: true
    }

    extension = extension.sub(/^\./, '').downcase
    if Rails.configuration.image_extensions.include?(extension)
      defaults[:upload_type] = 'image'
    elsif Rails.configuration.video_extensions.include?(extension)
      defaults[:upload_type] = 'video'
    else
      defaults[:is_shareable_via_social_media] = false
      defaults[:preview]                       = ''
      defaults[:status]                        = 'loading to MASI'
      defaults[:thumbnail]                     = ''
      defaults[:upload_type]                   = 'file'
    end

    # don't clobber any attributes that have been explicitly set
    assign_attributes(defaults.with_indifferent_access.merge(attributes) { |_key, oldval, newval| newval.nil? ? oldval : newval })
  end

  def blitline_callback_url
    url_for(controller: 'image_upload_callback', action: 'dl_image_blitline', host: ENV['APP_DOMAIN'])
  end

  def zencoder_callback_url
    url_for(controller: 'image_upload_callback', action: 'dl_image_zencoder', host: ENV['APP_DOMAIN'])
  end
end
