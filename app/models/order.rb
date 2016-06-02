# == Schema Information
#
# Table name: orders
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  fulfillment_method_id    :integer
#  bill_first_name          :string(255)
#  bill_last_name           :string(255)
#  bill_address_1           :string(255)
#  bill_address_2           :string(255)
#  bill_city                :string(255)
#  bill_state               :string(255)
#  bill_zip_code            :string(255)
#  bill_phone_number        :string(255)
#  bill_fax_number          :string(255)
#  bill_email_address       :string(255)
#  bill_comments            :text
#  bill_method              :string(255)
#  ship_first_name          :string(255)
#  ship_last_name           :string(255)
#  ship_address_1           :string(255)
#  ship_address_2           :string(255)
#  ship_city                :string(255)
#  ship_state               :string(255)
#  ship_zip_code            :string(255)
#  ship_phone_number        :string(255)
#  ship_fax_number          :string(255)
#  ship_email_address       :string(255)
#  ship_comments            :text
#  shipping_method          :string(255)
#  vendor_po_number         :string(255)
#  status                   :text             default("open")
#  tracking_number          :string(255)
#  order_comments           :text
#  currency_type            :string(255)
#  sub_total                :decimal(, )
#  tax                      :decimal(, )
#  handling                 :decimal(, )
#  total                    :decimal(, )
#  created_at               :datetime
#  updated_at               :datetime
#  submitted_at             :datetime
#  completed_at             :datetime
#  shipping                 :decimal(, )
#  same_billing_shipping    :boolean
#  bill_country             :string(255)
#  ship_country             :string(255)
#  bill_cost_center         :string(255)
#  bill_external_account_id :string(255)
#  bill_company_name        :string(255)
#  ship_company_name        :string(255)
#  order_date               :datetime
#

# class Order < ActiveRecord::Base
class Order < ActiveRecord::Base
  before_save :update_total
  before_save :verify_same_billing_shipping
  belongs_to :user
  belongs_to :fulfillment_method
  has_many :order_items
  has_many :operation_queues, as: :operable

  accepts_nested_attributes_for :order_items
  default_scope { order(id: :asc) }
  scope :history, -> { where('status != ?', 'open') }
  scope :active, -> { where(status: 'open') }
  scope :incomplete, -> { where("#{table_name}.status not in ('complete','cancelled','shipped')") }

  def valid_order?
    valid_billing_address? && valid_shipping_address?
  end

  def valid_billing_address?
    bill_first_name.present? && bill_last_name.present? && bill_address_1.present? && bill_city.present? && bill_state.present? && bill_zip_code.present? && bill_phone_number.present? && bill_email_address.present?
  end

  def valid_shipping_address?
    same_billing_shipping && valid_billing_address? || (ship_first_name.present? && ship_last_name.present? && ship_address_1.present? && ship_city.present? && ship_state.present? && ship_zip_code.present? && ship_phone_number.present? && ship_email_address.present?)
  end

  def complete!
    self.status = 'complete'
    save!
  end

  def cancelled!
    self.status = 'complete'
    save!
  end

  def set_same_billing_shipping
    self.ship_first_name = bill_first_name
    self.ship_last_name = bill_last_name
    self.ship_address_1 = bill_address_1
    self.ship_address_2 = bill_address_2
    self.ship_city = bill_city
    self.ship_state = bill_state
    self.ship_zip_code = bill_zip_code
    self.ship_phone_number = bill_phone_number
    self.ship_fax_number = bill_fax_number
    self.ship_email_address = bill_email_address
  end

  def open?
    status == 'open'
  end

  def inprocess?
    status == 'inprocess'
  end

  def complete?
    status == 'complete'
  end

  def update_total
    self.sub_total = 0
    order_items.each do |item|
      self.sub_total += item.item_total
      # calculate_shipping
      # self.handling = 0
    end
    self.total = sub_total
  end

  def calculate_shipping
    # fed ex based upon shipping_method
  end

  def calculate_handling
    # stub
  end

  private

  def verify_same_billing_shipping
    set_same_billing_shipping if same_billing_shipping
  end
end
