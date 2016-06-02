# == Schema Information
#
# Table name: email_lists
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string(255)
#  title      :string(255)
#  sheet      :text
#  token      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# class EmailList < ActiveRecord::Base
class EmailList < ActiveRecord::Base
  default_scope { order(id: :desc) }
  require 'spreadsheet'
  belongs_to :user
  include Sendgridable
  include Tokenable
  include Sheetable
  include OptOutable
  mount_uploader :sheet, SheetUploader

  validates :title, presence: true
  validates :name, presence: true, uniqueness: true

  def recipient_list
    # column inspection
    required_fields = {
      'email' => ['email', 'email_address', 'email address', 'EMAIL', 'EMAIL_ADDRESS', 'EMAIL ADDRESS', 'Email', 'Email Address'],
      'name' => ['name', 'NAME', 'Name', 'Name ']
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
      next unless test_recipient['email'].present? && test_recipient['name'].present?
      next unless test_recipient['email'].match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
      recipients << test_recipient
    end
    logger.debug 'recipients: ' + recipients.to_s
    recipients
  end

  def sendgrid_remove_opt_outs
    opt_outs = opt_out_emails
    list_recipients = sendgrid_get_list_email
    return nil unless  list_recipients.present?
    list_recipients = JSON.parse(list_recipients)
    remove_list = []
    list_recipients.each do |recipient|
      next unless opt_outs.include?(recipient['email'])
      remove_list << recipient['email']
    end
    sendgrid_delete_list_email(remove_list) if remove_list.present?
    # return list of removed emails
    remove_list
  end

  # LIST EMAIL
  def scrub_emails(emails)
    scrubbed_emails = []
    opt_outs = opt_out_emails
    emails.each do |email|
      next if opt_outs.include?(email['email'])
      scrubbed_emails << email
    end
    scrubbed_emails
  end

  # SENDGRID EMAIL
  def sendgrid_add_email
    logger.debug 'sendgrid_add_email'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/lists/email/add.json')
    emails = scrub_emails(recipient_list)
    return false if emails.length == 0
    emails.each_slice(1000).to_a.each do |email_chunk|
      response = sendgrid_dispatch_request(url, _sendgrid_add_list_email_params(email_chunk))
      case response.code.to_s
      when '401'
        # list creation failed
        return false
      else
        # list created
      end
    end
    true
  end

  def _sendgrid_add_list_email_params(data)
    logger.debug '_sendgrid_add_list_email_params' + data.to_s
    params = {}
    if data.length == 1
      params = {
        'api_user' => SENDGRID_USERNAME,
        'api_key' => SENDGRID_PASSWORD,
        'list' => name,
        'data' => data[0].to_json,
        # 'name' => 'column_name_goes_here'
      }
    else
      params = {
        'api_user' => SENDGRID_USERNAME,
        'api_key' => SENDGRID_PASSWORD,
        'list' => name,
        'data[]' => data.map(&:to_json),
        # 'name' => 'column_name_goes_here'
      }
    end
    params
  end

  def sendgrid_get_list_email
    logger.debug 'sendgrid_get_list_email'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/lists/email/get.json')
    response = sendgrid_dispatch_request(url, _sendgrid_get_list_email_params)
    case response.code.to_s
    when '401'
      # list creation failed
      return nil
    else
      # list created
    end
    response.body
  end

  def sendgrid_count_list_email
    logger.debug 'sendgrid_count_list_email'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/lists/email/count.json')
    sendgrid_dispatch_request(url, _sendgrid_get_list_email_params)
  end

  def _sendgrid_get_list_email_params
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'list' => name,
      # 'email' => 'asdf',
      # 'unsubscribed' => 1
    }
  end

  def sendgrid_delete_list_email(email)
    logger.debug 'sendgrid_delete_list_email'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/lists/email/delete.json')
    sendgrid_dispatch_request(url, _sendgrid_delete_list_email_params(email))
  end

  def _sendgrid_delete_list_email_params(email)
    params = {}
    if email.length == 1
      params = {
        'api_user' => SENDGRID_USERNAME,
        'api_key' => SENDGRID_PASSWORD,
        'list' => name,
        'email[]' => email[0],
        # 'unsubscribed' => 1
      }
    else
      params = {
        'api_user' => SENDGRID_USERNAME,
        'api_key' => SENDGRID_PASSWORD,
        'list' => name,
        'email[]' => email,
        # 'unsubscribed' => 1
      }
    end
    params
  end

  # LIST

  def sendgrid_create_list
    return nil if sendgrid_list_exists?
    response = sendgrid_add_list
    response_content = JSON.parse(response.body)
    logger.debug 'response_code ' + response.code.to_s
    logger.debug 'response_content: ' + response_content.to_s
    case response.code.to_s
    when '401'
      # list creation failed
      return false
    else
      # list created
      # add email addresses
      if sendgrid_add_email
        return true
      else
        sendgrid_delete_list
        return false
      end
    end
  end

  def sendgrid_list_exists?
    response = sendgrid_get_list
    response_content = JSON.parse(response.body)
    logger.debug 'response_code ' + response.code.to_s
    logger.debug 'response_content: ' + response_content.to_s
    case response.code.to_s
    when '401'
      # list does not exist
      return false
    else
      # list found
      return true
    end
  end

  # SENDGRID LIST
  def sendgrid_add_list
    logger.debug 'sendgrid_add_list'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/lists/add.json')
    sendgrid_dispatch_request(url, _sendgrid_list_params)
  end

  def sendgrid_get_list
    logger.debug 'sendgrid_get_list'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/lists/get.json')
    sendgrid_dispatch_request(url, _sendgrid_list_params)
  end

  def sendgrid_delete_list
    logger.debug 'sendgrid_delete_list'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/lists/delete.json')
    sendgrid_dispatch_request(url, _sendgrid_list_params)
  end

  def _sendgrid_list_params
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'list' => name,
      # 'name' => 'column_name_goes_here'
    }
  end

  # unnecessary at this point, since we do not provide actual name of list to sendgrid
  def sendgrid_edit_list
    logger.debug 'sendgrid_edit_list'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/lists/edit.json')
    sendgrid_dispatch_request(url, _sendgrid_edit_list_params)
  end

  def _sendgrid_edit_list_params
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'list' => name,
      'newname' => name
    }
  end
end
