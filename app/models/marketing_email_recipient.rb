# == Schema Information
#
# Table name: marketing_email_recipients
#
#  id                 :integer          not null, primary key
#  marketing_email_id :integer
#  email_address      :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

# class MarketingEmailRecipient < ActiveRecord::Base
class MarketingEmailRecipient < ActiveRecord::Base
  belongs_to :marketing_email
end
