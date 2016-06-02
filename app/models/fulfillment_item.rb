# == Schema Information
#
# Table name: fulfillment_items
#
#  id                    :integer          not null, primary key
#  fulfillable_type      :string(255)
#  fulfillable_id        :integer
#  fulfillment_method_id :integer
#  price_schedule        :text             default("{}")
#  price_per_unit        :decimal(, )
#  weight_per_unit       :decimal(, )
#  taxable               :boolean          default(TRUE)
#  description           :text
#  created_at            :datetime
#  updated_at            :datetime
#  vendor_item_id        :string(255)
#  mailing_list_item     :boolean          default(FALSE)
#  item_category         :string(255)
#  item_type             :string(255)
#  min_quantity          :integer
#  max_quantity          :integer
#

# class FulfillmentItem < ActiveRecord::Base
class FulfillmentItem < ActiveRecord::Base
  serialize :price_schedule, JSON
  belongs_to :fulfillment_method
  belongs_to :fulfillable, polymorphic: true

  def get_price(quantity)
    price_schedule_hash[quantity] || price_per_unit
  end

  def price_schedule_hash
    Hash[*price_schedule.flatten]
  end

  def price_schedule_quantities
    @quantities = []
    if price_schedule.present?
      price_schedule.each do |k, v|
        label = k.to_s
        label += ' @ ' + (sprintf('%.2f', v)).to_s if v.present?
        @quantities << [label, k.to_i]
      end
    end
    @quantities
  end
end
