# == Schema Information
#
# Table name: ac_images
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  title        :string(255)
#  thumbnail    :string(255)
#  preview      :string(255)
#  location     :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  filename     :string(255)
#  folder       :string(255)
#  expired      :boolean          default(FALSE)
#  status       :string(255)      default("inprocess")
#  token        :string(255)
#  bundle       :string(255)
#  user_id      :integer
#  job_id       :string(255)
#  s3_key       :string(255)
#  uploaded     :boolean
#  upload_type  :string(255)
#  publish_at   :datetime
#  unpublish_at :datetime
#

# class AcImage < ActiveRecord::Base
class AcImage < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include Publishable
  include Keywordable
  include Indexable
  include Respondable
  include Setable
  include Tokenable
  include DefaultImageHelper

  default_scope { where expired: false }

  has_and_belongs_to_many :keywords
  has_many :keywords, as: :searchable
  has_one :keyword_index, as: :indexable, dependent: :delete
  has_many :set_attributes, as: :setable, dependent: :delete_all
  has_many :responds_to_attributes, as: :respondable, dependent: :delete_all
  has_and_belongs_to_many :asset_access_levels
  has_many :asset_access_levels, as: :restrictable
  has_many :operation_queues, as: :operable
  belongs_to :user

  scope :admin, -> { where(status: %w(pre-publish production unpublished)) }
  scope :complete, -> { where(status: %w(complete staged)) }
  scope :incomplete, -> { where("#{table_name}.status not in ('unpublished','unstaged','processed','pre-publish','complete','production')") }

  mount_uploader :bundle, BundleUploader

  before_create :assign_attribute_defaults

  after_create do
    if upload_type == 'file'
      # skip external processing
      dispatch_admin_request
      add_default_keywords
    end
  end

  def downloadable?
    true
  end

  def shareable?
    false
  end

  def shareable_via_email?
    false
  end

  def shareable_via_social_media?
    false
  end

  def image_uploader
    bundle
  end

  def admin_xml
    data = {
      app_id: APP_ID,
      bundle_location: bundle.url,
      filename: filename,
      image_complete_url: "#{admin_ac_image_staged_url}?token=#{token}",
      image_id: id.to_s,
      image_type: 'ac_images'
    }

    data.to_xml(root: 'ac_image', dasherize: false)
  end

  def asset_type
    self.class.name
  end

  def bundle_url
    SECURE_BASE_URL + '/ac_images/' + APP_ID + '/' + id.to_s + '/' + id.to_s + '.zip'
  end

  def cart_files
    @cart_files = []
    if self.video?
      ext = File.extname(bundle.path)
      @cart_files << { 'url' => bundle.url, 'path' => bundle.path }
      @cart_files << { 'url' => bundle.wmv.url, 'path' => bundle.wmv.path } unless ext.downcase == '.wmv'
      @cart_files << { 'url' => bundle.mov.url, 'path' => bundle.mov.path } unless ext.downcase == '.mov'
    else
      ext = File.extname(location)
      path = File.dirname(location) + '/'
      @cart_files << { 'location' => path + 'preview.jpg' } unless ext.downcase == '.jpg'
      @cart_files << { 'location' => path + 'preview.png' } unless ext.downcase == '.png'
      @cart_files << { 'location' => location }
    end
    logger.debug @cart_files
    @cart_files
  end

  def categorizable_class
    'categorizable'
  end

  def dispatch_admin_request
    url = URI.parse("#{ADMIN_URL}/ac_image_#{APP_ID}_#{id}.xml")
    request = Net::HTTP::Put.new(url.path)
    request.body = admin_xml
    Net::HTTP.start(url.host, url.port) { |http| http.request(request) }
  end

  def downloadable_class
    ''
  end

  def expire!
    pub_expire
    save!
  end

  def extension
    File.extname(location.to_s)
  end

  def file?
    true
  end

  def image?
    true
  end

  def preview_url
    SECURE_BASE_URL + thumbnail
  end

  def shareable_class
    ''
  end

  def thumbnail_url
    if thumbnail.present?
      SECURE_BASE_URL + thumbnail
    else
      default_image
    end
  end

  def audio?
    false
  end

  def video?
    false
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
      defaults[:preview]     = ''
      defaults[:status]      = 'loading to MASI'
      defaults[:thumbnail]   = ''
      defaults[:upload_type] = 'file'
    end

    # don't clobber any attributes that have been explicitly set
    assign_attributes(defaults.with_indifferent_access.merge(attributes) { |_key, oldval, newval| newval.nil? ? oldval : newval })
  end
end
