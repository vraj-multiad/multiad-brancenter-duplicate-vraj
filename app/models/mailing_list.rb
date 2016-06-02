# == Schema Information
#
# Table name: mailing_lists
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string(255)
#  title      :string(255)
#  sheet      :text
#  status     :string(255)
#  list_type  :string(255)
#  token      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  quantity   :integer
#

class MailingList < ActiveRecord::Base
  include Tokenable
  include Sheetable
  belongs_to :user
  has_many :order_items
  has_many :operation_queues, as: :operable

  mount_uploader :sheet, SheetUploader

  def recipient_list
    # column inspection
    required_fields = {
      'name' => ['name', 'NAME', 'Name', 'Name '],
      'first' => ['first', 'FIRST', 'First', 'first name', 'FIRST NAME', 'First Name', 'first_name', 'FIRST_NAME', 'First_Name'],
      'last' => ['last', 'LAST', 'Last', 'last name', 'LAST NAME', 'Last Name', 'last_name', 'LAST_NAME', 'Last_Name'],
      'address' => ['address', 'address_1', 'address 1', 'ADDRESS', 'ADDRESS_1', 'ADDRESS 1', 'Address', 'Address_1', 'Address 1'],
      'city' => ['city', 'CITY', 'City'],
      'state' => ['state', 'STATE', 'State', 'Province', 'PROVINCE', 'Province'],
      'zip' => ['zip', 'ZIP', 'Zip', 'POSTAL CODE', 'POSTAL_CODE', 'Postal Code', 'Postal_Code'],
    }
    recipients = []
    sheet_data.each do |recipient|
      test_recipient = {}
      required_fields.each do |field_name, keys|
        logger.debug 'field_name: ' + field_name.to_s
        logger.debug 'keys: ' + keys.to_s
        keys.each do |key|
          if recipient[key].present?
            test_recipient[field_name] = recipient[key]
            break
          end
        end
      end
      next unless (test_recipient['name'].present? || (test_recipient['first'].present? && test_recipient['last'].present?)) && test_recipient['address'].present? && test_recipient['city'].present? && test_recipient['state'].present? && test_recipient['zip'].present?
      recipients << test_recipient
    end
    logger.debug 'recipients: ' + recipients.to_s
    recipients
  end
end
