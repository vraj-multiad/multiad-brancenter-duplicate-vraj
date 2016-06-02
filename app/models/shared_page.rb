# == Schema Information
#
# Table name: shared_pages
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  token           :string(255)
#  expiration_date :date
#  created_at      :datetime
#  updated_at      :datetime
#

class SharedPage < ActiveRecord::Base
  include Tokenable
  belongs_to :user
  has_many :shared_page_views
  has_many :shared_page_items
  has_many :shared_page_downloads
  before_create :set_expiration_date

  def expire!
    self.expiration_date = Time.zone.now
    save
  end

  def set_expiration_date
    self.expiration_date = Time.zone.now + SHARED_PAGE_DURATION.days
  end

  def share_link
    APP_DOMAIN + '/shared_assets/page?asset_id=' + token
  end

  def share_preview
    SECURE_BASE_URL + '/brandcenter-header-logo.png'
  end

  def share_url
    SECURE_BASE_URL + '/brandcenter-header-logo.png'
  end

  def title
    ''
  end
end
