# == Schema Information
#
# Table name: order_items
#
#  id                  :integer          not null, primary key
#  order_id            :integer
#  orderable_type      :string(255)
#  orderable_id        :integer
#  vendor_item_number  :string(255)
#  description         :text
#  quantity            :integer
#  unit_price          :decimal(, )
#  item_total          :decimal(, )
#  created_at          :datetime
#  updated_at          :datetime
#  fulfillment_item_id :integer
#  ac_export_id        :integer
#  comments            :text
#  mailing_list_id     :integer
#  tracking_number     :string(255)
#  status              :string(255)
#

# class OrderItem < ActiveRecord::Base
class OrderItem < ActiveRecord::Base
  before_save :update_price_and_total
  after_save :update_order_total
  belongs_to :ac_export
  belongs_to :order
  belongs_to :fulfillment_item
  belongs_to :fulfillable, polymorphic: true
  belongs_to :orderable, polymorphic: true
  belongs_to :mailing_list
  has_many :operation_queues, as: :operable

  def thumbnail
    if ac_export_id.present?
      ac_export.thumbnail
    else
      orderable.thumbnail
    end
  end

  def download
    if ac_export_id.present?
      ac_export.location
    else
      orderable.location
    end
  end

  def thumbnail_url
    if ac_export_id.present?
      ac_export.thumbnail_url
    else
      orderable.thumbnail_url
    end
  end

  def download_url
    if ac_export_id.present?
      PICKUP_URL + ac_export.location
    else
      PICKUP_URL + orderable.location
    end
  end

  private

  def update_order_total
    order.update_total
    order.save
  end

  def update_price_and_total
    return false unless fulfillment_item.present?
    self.quantity = mailing_list.quantity if mailing_list.present?
    self.unit_price = fulfillment_item.get_price quantity
    self.item_total = unit_price * quantity
  end
end
