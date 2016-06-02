# == Schema Information
#
# Table name: dl_image_groups
#
#  id               :integer          not null, primary key
#  main_dl_image_id :integer
#  name             :string(255)
#  title            :string(255)
#  description      :text
#  created_at       :datetime
#  updated_at       :datetime
#  user_id          :integer
#  token            :string(255)
#

# class DlImageGroup < ActiveRecord::Base
class DlImageGroup < ActiveRecord::Base
  include Tokenable
  include Indexable

  default_scope { order(id: :desc) }

  before_destroy :remove_keywords
  before_destroy :remove_user_keywords
  after_save :rebuild_searchable
  after_save :rebuild_restrictable
  belongs_to :user
  has_and_belongs_to_many :user_keywords
  has_many :user_keywords, as: :categorizable
  has_many :shared_page_items, as: :shareable
  has_many :dl_cart_items, as: :downloadable
  ### keywords and access_levels will be generated via save hook from child dl_image
  has_and_belongs_to_many :keywords
  has_many :keywords, as: :searchable
  has_one :keyword_index, as: :indexable, dependent: :delete
  has_and_belongs_to_many :asset_access_levels
  has_many :asset_access_levels, as: :restrictable
  has_and_belongs_to_many :dl_images, join_table: :dl_image_groups_dl_images
  has_many :operation_queues, as: :operable

  def self.prune
    DlImageGroup.all.each do |dlig|
      dlig.destroy unless dlig.dl_images.present?
    end
  end

  def expired
    false
  end

  def upload_type
    'multiple'
  end

  def downloadable?
    dl_images.where(is_downloadable: true).present?
  end

  def shareable?
    shareable_via_social_media? || shareable_via_email?
  end

  def shareable_via_email?
    dl_images.where(is_shareable_via_email: true).present?
  end

  def shareable_via_social_media?
    ENABLE_SOCIAL_MEDIA && dl_images.where(is_shareable_via_social_media: true).present?
  end

  def share_preview(user_id)
    share = main_image(user_id)
    if share.thumbnail.present?
      SECURE_BASE_URL + share.thumbnail
    elsif share.video? || share.image?  # 'file'
      share.bundle.thumbnail.url
    end
  end

  def share_url(user_id)
    share = main_image(user_id)
    if share.thumbnail.present?
      SECURE_BASE_URL + share.thumbnail
    else
      if share.video?
        share.bundle.url
      else
        share.bundle.url
      end
    end
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

  def favorite?(user_id)
    user_keywords.where(user_id: user_id, title: 'Favorites', term: 'favorites').count > 0
  end

  def main_image(user_id, require_production = false)
    user = User.find(user_id)
    permitted_main_image = DlImage.where(id: main_dl_image_id).user_permitted(user.id)
    permitted_main_image = permitted_main_image.where(status: 'production') if require_production
    main_image = permitted_main_image.first if permitted_main_image.present?
    unless main_image.present?
      permitted_main_image = dl_images.user_permitted(user.id)
      permitted_main_image = permitted_main_image.where(status: 'production') if require_production
      main_image = permitted_main_image.first if permitted_main_image.present?
    end
    main_image
  end

  def main_image_shared_email(user_id, require_production = false)
    user = User.find(user_id)
    permitted_main_image = DlImage.where(id: main_dl_image_id, is_shareable_via_email: true).user_permitted(user.id)
    permitted_main_image = permitted_main_image.where(status: 'production') if require_production
    main_image = permitted_main_image.first if permitted_main_image.present?
    unless main_image.present?
      permitted_main_image = dl_images.where(is_shareable_via_email: true).user_permitted(user.id)
      permitted_main_image = permitted_main_image.where(status: 'production') if require_production
      main_image = permitted_main_image.first if permitted_main_image.present?
    end
    main_image
  end

  def main_image_shared_social_media(user_id, require_production = false)
    user = User.find(user_id)
    permitted_main_image = DlImage.where(id: main_dl_image_id, is_shareable_via_social_media: true).user_permitted(user.id)
    permitted_main_image = permitted_main_image.where(status: 'production') if require_production
    main_image = permitted_main_image.first if permitted_main_image.present?
    unless main_image.present?
      permitted_main_image = dl_images.where(is_shareable_via_social_media: true).user_permitted(user.id)
      permitted_main_image = permitted_main_image.where(status: 'production') if require_production
      main_image = permitted_main_image.first if permitted_main_image.present?
    end
    main_image
  end

  ########################################################

  def remove_keywords
    keywords.destroy_all
  end

  def remove_user_keywords
    user_keywords.destroy_all
  end

  # need to verify that only available images make it into the image group
  def rebuild_searchable
    keywords.destroy_all
    dl_images.reload.eager_load(:keywords).pluck('distinct keyword_type, term').each do |keyword_type, term|
      keywords.find_or_create_by(keyword_type: keyword_type, term: term)
    end
    # add name and title
    keywords.find_or_create_by(keyword_type: 'system', term: name.to_s.downcase) if name.present?
    keywords.find_or_create_by(keyword_type: 'system', term: title.to_s.downcase) if title.present?
    keywords.find_or_create_by(keyword_type: 'system', term: description.to_s.downcase) if description.present?
  end

  def rebuild_restrictable
    asset_access_levels.destroy_all
    dl_images.eager_load(:asset_access_levels).pluck('distinct access_level_id').each do |access_level_id|
      next unless access_level_id.present?
      asset_access_levels.find_or_create_by(access_level_id: access_level_id)
    end
  end
end
