# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  title                  :string(255)
#  address_1              :string(255)
#  address_2              :string(255)
#  city                   :string(255)
#  state                  :string(255)
#  zip_code               :string(255)
#  phone_number           :string(255)
#  fax_number             :string(255)
#  email_address          :string(255)
#  username               :string(255)
#  password_digest        :string(255)
#  last_login             :datetime
#  license_agreement_flag :boolean          default(FALSE)
#  update_profile_flag    :boolean          default(FALSE)
#  ship_first_name        :string(255)
#  ship_last_name         :string(255)
#  ship_address_1         :string(255)
#  ship_address_2         :string(255)
#  ship_city              :string(255)
#  ship_state             :string(255)
#  ship_zip_code          :string(255)
#  ship_phone_number      :string(255)
#  ship_fax_number        :string(255)
#  ship_email_address     :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  same_billing_shipping  :boolean          default(FALSE)
#  token                  :string(255)
#  activated              :boolean          default(FALSE)
#  user_type              :string(255)      default("user")
#  expired                :boolean          default(FALSE)
#  mobile_number          :string(255)
#  website                :string(255)
#  company_name           :string(255)
#  country                :string(255)
#  ship_country           :string(255)
#  role_id                :integer
#  external_account_id    :string(255)
#  cost_center            :string(255)
#  ship_company_name      :string(255)
#  sso_flag               :boolean          default(FALSE)
#  facebook_id            :string(255)
#  linkedin_id            :string(255)
#  twitter_id             :string(255)
#

# class User < ActiveRecord::Base
class User < ActiveRecord::Base
  include Tokenable
  has_secure_password

  attr_accessor :email_address_confirmation

  belongs_to :role
  has_and_belongs_to_many :roles, join_table: :roles_users
  has_and_belongs_to_many :access_levels, join_table: :user_access_levels
  has_many :ac_sessions
  has_many :ac_session_histories, through: :ac_sessions
  has_many :ac_exports, through: :ac_session_histories
  has_many :user_uploaded_images
  has_many :searches
  has_many :user_keywords
  has_many :keywords, through: :searches
  has_many :user_downloads
  has_many :dl_carts
  has_many :dl_cart_items, through: :dl_carts
  has_many :shared_pages
  has_many :shared_page_items, through: :shared_pages
  has_many :shared_page_downloads, through: :shared_pages
  has_many :social_media_accounts
  has_many :dl_images
  has_many :dl_image_groups
  has_many :ac_images
  has_many :ac_creator_templates
  has_many :ac_texts
  has_many :orders
  has_many :email_lists
  has_many :marketing_emails
  has_many :order_items, through: :orders
  has_one :active_cart, -> { active }, class_name: 'Order'
  has_many :click_events
  has_many :mailing_lists
  has_many :operation_queues, as: :operable
  has_many :contacts

  validates_confirmation_of :password, on: :create
  validates :username, presence: true,
                       length: { minimum: 4 },
                       uniqueness: true
  validates :email_address, presence: true,
                            uniqueness: true,
                            format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create },
                            confirmation: true
  validates :first_name, presence: true, if: ->  { REQUIRE_FIRST_NAME }
  validates :last_name, presence: true, if: ->  { REQUIRE_LAST_NAME }
  validates :title, presence: true, if: ->  { REQUIRE_TITLE }
  validates :address_1, presence: true, if: ->  { REQUIRE_ADDRESS_1 }
  validates :address_2, presence: true, if: ->  { REQUIRE_ADDRESS_2 }
  validates :city, presence: true, if: ->  { REQUIRE_CITY }
  validates :state, presence: true, if: ->  { REQUIRE_STATE }
  validates :zip_code, presence: true, if: ->  { REQUIRE_ZIP_CODE }
  validates :country, presence: true, if: ->  { REQUIRE_COUNTRY }
  validates :phone_number, presence: true, if: ->  { REQUIRE_PHONE_NUMBER }
  validates :fax_number, presence: true, if: ->  { REQUIRE_FAX_NUMBER }
  validates :mobile_number, presence: true, if: ->  { REQUIRE_MOBILE_NUMBER }
  validates :website, presence: true, if: ->  { REQUIRE_WEBSITE }
  validates :company_name, presence: true, if: ->  { REQUIRE_COMPANY_NAME }

  default_scope { order(username: :asc) }
  scope :admin_and_below, -> { where(user_type: %w(user contributor admin)) }
  scope :contributor_and_below, -> { where(user_type: %w(user contributor)) }
  scope :activated, -> { where(activated: true, expired: false) }
  scope :active, -> { where(expired: false) }
  scope :expired, -> { where(expired: true) }

  def facebook_account
    @facebook_account ||= FacebookAccount.where(user_id: id).first_or_create
  end

  def twitter_account
    @twitter_account ||= TwitterAccount.where(user_id: id).first_or_create
  end

  def youtube_account
    @youtube_account ||= YoutubeAccount.where(user_id: id).first_or_create
  end

  def active_cart_items
    cart = Order.where(user_id: id).active
    if cart.count > 0
      cart.first.order_items.count
    else
      0
    end
  end

  def active_cart
    cart = super
    logger.debug cart.inspect
    if cart.nil?
      logger.debug 'cart created'
      cart = Order.create(order_params)
      # init stuff
      super(true) # make sure active record finds the newly created cart
    end
    cart
  end

  def superuser?
    user_type == 'superuser'
  end

  def admin?
    user_type == 'admin'
  end

  def contributor?
    user_type == 'contributor'
  end

  def has_access?(access_level_id)
    superuser? || access_levels.where(id: access_level_id).count == 1
  end

  def permissions
    if superuser?
      @access_levels ||= AccessLevel.all
    else
      @access_levels ||= access_levels
    end
  end

  def admin_permissions
    if superuser?
      @access_levels ||= AccessLevel.all
    else
      if access_levels.count < AccessLevel.all.count
        @access_levels ||= access_levels.where.not(name: 'everyone')
      else
        @access_levels ||= access_levels
      end
    end
  end

  def permitted_keyword_type(keyword_type)
    KeywordTerm.where(keyword_type: keyword_type, access_level_id: permissions.pluck(:id))
  end

  def order_params
    params = { user: self,
               bill_first_name: first_name,
               bill_last_name: last_name,
               bill_address_1: address_1,
               bill_address_2: address_2,
               bill_city: city,
               bill_state: state,
               bill_zip_code: zip_code,
               bill_phone_number: phone_number,
               bill_fax_number: fax_number,
               bill_email_address: email_address,
               bill_cost_center: cost_center,
               bill_external_account_id: external_account_id,
               same_billing_shipping: same_billing_shipping,
               bill_company_name: company_name,
               bill_country: country
    }
    if same_billing_shipping
      params.merge!(ship_first_name: first_name,
                    ship_last_name: last_name,
                    ship_address_1: address_1,
                    ship_address_2: address_2,
                    ship_city: city,
                    ship_state: state,
                    ship_zip_code: zip_code,
                    ship_phone_number: phone_number,
                    ship_fax_number: fax_number,
                    ship_country: country,
                    ship_company_name: company_name,
                    ship_email_address: email_address)
    else
      params.merge!(ship_first_name: ship_first_name,
                    ship_last_name: ship_last_name,
                    ship_address_1: ship_address_1,
                    ship_address_2: ship_address_2,
                    ship_city: ship_city,
                    ship_state: ship_state,
                    ship_zip_code: ship_zip_code,
                    ship_phone_number: ship_phone_number,
                    ship_fax_number: ship_fax_number,
                    ship_country: country,
                    ship_company_name: company_name,
                    ship_email_address: ship_email_address)
    end
    params['fulfillment_method_id'] = FulfillmentMethod.first.id
    params
  end

  def set_role
    return unless role.present?
    access_levels.destroy_all
    access_levels << role.access_levels
  end

  def init_access_level
    access_levels.destroy_all
    access_level = AccessLevel.find_by(name: 'everyone')
    access_levels << access_level
  end

  def mailing_lists_select(min, max)
    select = [['','']]
    mailing_lists.each do |ml|
      next if min.present? && ml.quantity < min
      next if max.present? && ml.quantity > max
      select << [ml.title.to_s + ' (' + ml.quantity.to_s + ')', ml.id.to_s]
    end
    select
  end

  def system_contacts_user?
    username == 'SYSTEM CONTACTS'
  end

  def enabled(property)
    return true unless role.present?
    case property
    when 'enable_upload_mailing_list'
      return role.enable_upload_mailing_list.present?
    end
  end

  # def has_password
  #   attr_reader :password
  #   validates :password_digest, presence: true
  #   # validates :verify_password, presence: true
  # end
  # validates_confirmation_of :email_address
end
