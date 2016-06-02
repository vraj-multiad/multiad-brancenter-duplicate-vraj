# == Schema Information
#
# Table name: user_uploaded_images
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  image_upload                  :string(255)
#  filename                      :string(255)
#  extension                     :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  user_id                       :integer
#  expired                       :boolean          default(FALSE)
#  upload_type                   :string(255)
#  s3_key                        :string(255)
#  uploaded                      :boolean          default(FALSE)
#  title                         :string(255)
#  status                        :string(255)
#  token                         :string(255)
#  job_id                        :string(255)
#  category_count                :integer
#  keyword_count                 :integer
#  is_shareable                  :boolean          default(TRUE)
#  is_shareable_via_social_media :boolean          default(TRUE)
#  is_shareable_via_email        :boolean          default(TRUE)
#  processed_types               :text
#  s3_poll_count                 :integer          default(0)
#  is_downloadable               :boolean          default(TRUE)
#  description                   :text
#

require 'carrierwave/orm/activerecord'
class UserUploadedImage < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include Blitlineable
  include Indexable
  include Tokenable
  include Zencodable
  include DefaultImageHelper

  INDEXABLE_UPLOAD_TYPES = %w(library library_video library_image library_file)

  default_scope { where expired: false }

  belongs_to :user
  has_many :set_attributes, as: :setable
  has_many :responds_to_attributes, as: :respondable
  has_many :shared_page_items, as: :shareable
  has_many :user_keywords, as: :categorizable
  has_many :dl_cart_items, as: :downloadable
  has_many :operation_queues, as: :operable
  has_one :keyword_index, as: :indexable, dependent: :delete

  before_create :assign_attribute_defaults
  after_create  do
    process_upload
    assign_system_user_keywords
  end

  mount_uploader :image_upload, ImageUploadUploader

  scope :available, -> { where expired: false }
  scope :ac_image, -> { where upload_type: 'ac_image' }
  scope :attachment, -> { where upload_type: %w(attachment) }
  scope :logo, -> { where upload_type: 'logo' }
  scope :library, -> { where upload_type: INDEXABLE_UPLOAD_TYPES }
  # scope :processing, -> { where uploaded: false }  #### time limit for last modified > now - 30
  scope :processing, -> { where("#{table_name}.status is NULL or #{table_name}.status = 'processing' ") }  #### time limit for last modified > now - 30
  scope :processed, -> { where status: 'processed' }
  scope :complete, -> { where status: 'complete' }
  scope :incomplete, -> { where.not status: 'complete' }
  scope :uncategorized, -> { where("#{table_name}.category_count is null or #{table_name}.category_count = 0") }    #### no keywords...
  scope :unkeyworded, -> { where("#{table_name}.keyword_count is null or #{table_name}.keyword_count = 0") }    #### no keywords...

  def assign_system_user_keywords
    # make title searchable where applicable
    return unless title.present? && indexable?
    user_keywords.system.destroy_all
    user_keywords.create(term: title.downcase, title: title.downcase, user_keyword_type: 'system', user_id: user_id)
  end

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

  def indexable?
    INDEXABLE_UPLOAD_TYPES.include?(upload_type)
  end

  def favorite?(user_id)
    user_keywords.where(user_id: user_id, title: 'Favorites', term: 'favorites').count > 0
  end

  # instance variable isn't doing anything?
  def cart_files
    @cart_files = []

    ext = File.extname(image_upload.original.path)
    if video?
      @cart_files << { 'url' => image_upload.original.url, 'path' => image_upload.original.path, 'unique_name' => token.to_s + ext.downcase }
      @cart_files << { 'url' => image_upload.wmv.url, 'path' => image_upload.wmv.path, 'unique_name' => token.to_s + '.wmv' } unless ext.downcase == '.wmv'
      @cart_files << { 'url' => image_upload.mov.url, 'path' => image_upload.mov.path, 'unique_name' => token.to_s + '.mov' } unless ext.downcase == '.mov'
    elsif image? && ext.downcase != '.pdf'
      @cart_files << { 'url' => image_upload_url, 'path' => image_upload.path, 'unique_name' => token.to_s + ext.downcase }
      @cart_files << { 'url' => image_upload.png.url, 'path' => image_upload.png.path, 'unique_name' => token.to_s + '.png' } unless ext.downcase == '.png'
      @cart_files << { 'url' => image_upload.jpg.url, 'path' => image_upload.jpg.path, 'unique_name' => token.to_s + '.jpg' } unless ext.downcase == '.jpg'
    else
      @cart_files << { 'url' => image_upload_url, 'path' => image_upload.path, 'unique_name' => token.to_s + '.' + ext.downcase }
    end

    logger.debug @cart_files
    @cart_files
  end

  # self.class.to_s
  def asset_type
    'UserUploadedImage'
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

  def expire!
    user_keywords.destroy_all
    self.expired = true
    self.status = 'complete'
    save!
  end

  def file?
    case upload_type
    when 'library_file', 'attachment'
      true
    else
      false
    end
  end

  def image?
    case upload_type
    when 'library_image', 'profile_logo', 'ac_image'
      true
    else
      false
    end
  end

  def audio?
    ext = File.extname(image_upload.filename).downcase
    if upload_type == 'library_file' && ext == '.mp3'
      true
    else
      false
    end
  end

  def video?
    case upload_type
    when 'library_video'
      true
    else
      false
    end
  end

  def share_preview
    case upload_type
    when 'ac_image', 'logo', 'library_image'
      image_upload.thumbnail.url
    when 'library_video'
      image_upload.thumbnail.url
    when 'library_file', 'attachment'
      thumbnail_url
    end
  end

  def share_url
    case upload_type
    when 'ac_image', 'logo', 'library_image'
      image_upload.preview.url
    when 'library_video'
      image_upload.url
    when 'library_file', 'attachment'
      return image_upload.url if audio?
      thumbnail_url
    end
  end

  def thumbnail_url
    case upload_type
    when 'ac_image', 'logo', 'library_image'
      image_upload.thumbnail.url
    when 'attachment'
      APP_DOMAIN + '/assets/' + default_images('xxx.xxx')
    when 'library_video'
      image_upload.thumbnail.url
    when 'library_file'
      APP_DOMAIN + '/assets/' + default_images(image_upload.original.path)
    end
  end

  def preview_url
    case upload_type
    when 'ac_image', 'logo', 'library_image'
      image_upload.preview.url
    when 'library_video'
      image_upload.url
    when 'library_file', 'attachment'
      thumbnail_url
    end
  end

  def video_preview_url
    image_upload.preview.url if video?
  end

  def process_upload
    case upload_type
    when 'library_image', 'logo', 'ac_image'
      create_images
    when 'library_video'
      create_videos
    when 'attachment'
      # do nothing
    when 'library_file'
      self.status = 'processed'
      self.save!
    else
      logger.warn "unregistered upload_type: #{upload_type}"
    end
  end

  # should this alias_method instead?
  def image_uploader
    image_upload
  end

  private

  # TODO: should this go in s3able?
  def assign_attribute_defaults
    basename = File.basename(image_uploader.key)

    defaults = {
      filename: basename,
      title: basename,
      uploaded: true # TODO: get rid of this?
    }

    assign_attributes(defaults.with_indifferent_access.merge(attributes) { |_key, oldval, newval| newval.nil? ? oldval : newval })
  end

  def blitline_callback_url
    url_for(controller: 'image_upload_callback', action: 'user_uploaded_image_blitline', host: ENV['APP_DOMAIN'])
  end

  def zencoder_callback_url
    url_for(controller: 'image_upload_callback', action: 'user_uploaded_image_zencoder', host: ENV['APP_DOMAIN'])
  end
end
