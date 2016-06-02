# == Schema Information
#
# Table name: marketing_emails
#
#  id                     :integer          not null, primary key
#  ac_export_id           :integer
#  user_id                :integer
#  ac_creator_template_id :integer
#  ac_session_history_id  :integer
#  created_at             :datetime
#  updated_at             :datetime
#  location               :string(255)
#  email_list_id          :integer
#  subject                :string(255)
#  token                  :string(255)
#  status                 :string(255)
#  error_string           :text
#  user_error_string      :string(255)
#  reply_to               :string(255)
#  from_name              :string(255)
#  from_address           :string(255)
#

# class MarketingEmail < ActiveRecord::Base
class MarketingEmail < ActiveRecord::Base
  include Tokenable
  include Sendgridable

  belongs_to :ac_export
  belongs_to :user
  belongs_to :ac_creator_template
  belongs_to :ac_session_history
  belongs_to :email_list

  has_many :marketing_email_recipients

  validates :reply_to, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }, if: -> { reply_to.present? }
  validates :from_address, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }, if: -> { from_address.present? }

  def finished?
    %w(complete in_process).include?(status)
  end

  def html
    # pull the xml file referenced in documents
    uri = URI(AC_BASE_URL + location)
    Net::HTTP.get(uri)
  end

  def generate_error(error_string_param = nil, user_error_string_param = 'System Error')
    self.status = 'failed'
    self.user_error_string = user_error_string_param
    self.error_string = error_string_param || generate_error_string
    save
    nil
  end

  def generate_error_string
    errors = []
    errors << 'location not present' unless location.present?
    errors << 'email_list not present' unless email_list.present?
    errors << 'marketing_email_recipients already assigned' if marketing_email_recipients.present?
    errors.join("\n")
  end

  def sendgrid_submit_email
    return generate_error(generate_error_string, 'System Error') unless location.present? && email_list.present? && !marketing_email_recipients.present?

    ### adjust sendgrid_sender (identity) to properly reflect reply_to for this email.
    sendgrid_resolve_identity

    response = sendgrid_add_marketing_email
    return generate_error(response.code.to_s + '||' + 'sendgrid_add_marketing_email: ' + response_body.to_s) unless response.code.to_s == '200'

    logger.debug response.to_s
    # scrub list before send
    removed_recipients = email_list.sendgrid_remove_opt_outs
    logger.debug 'removed_recipients: ' + removed_recipients.to_s
    # add recipients
    recipient_response = sendgrid_add_marketing_email_recipients
    return generate_error(recipient_response.code.to_s + '||' + recipient_response.body.to_s, 'All requested recipients have opted out of future communications from Brandcenter.') unless recipient_response.code.to_s == '200'

    # recipients added
    list_recipients = email_list.sendgrid_get_list_email
    # don't schedule empty email recipient list
    return generate_error('list_recipients not present') unless list_recipients.present?

    # record marketing_email_recipients
    JSON.parse(list_recipients).each do |email|
      marketing_email_recipients << MarketingEmailRecipient.create!(email_address: email.to_s)
    end
    # add unique category
    category_response = sendgrid_set_marketing_email_category
    return generate_error(category_response.code.to_s + '||' + category_response.body.to_s) unless category_response.code.to_s == '200'

    # add schedule
    schedule_response = sendgrid_add_marketing_email_schedule
    return generate_error(schedule_response.code.to_s + '||' + schedule_response.body.to_s) unless schedule_response.code.to_s == '200'

    self.status = 'complete'
    self.user_error_string = ''
    save
    # move to a spec at a later date
    # extract schduled date
    # get_schedule = sendgrid_get_marketing_email_schedule
    # logger.debug get_schedule.to_s
    # remove email
    # delete_schedule = sendgrid_delete_marketing_email_schedule
    # logger.debug delete_schedule.to_s
  end

  # Get stats on email
  def sendgrid_get_email_stats
    response = sendgrid_get_category_stats(created_at.strftime('%Y-%m-%d'), nil, nil, [sendgrid_marketing_email_name])
    logger.debug 'response_code: ' + response.code.to_s
    case response.code.to_s
    when '200'
      logger.debug 'response.body: ' + response.body.to_s
      return JSON.parse(response.body)[0]['stats'][0]['metrics']
    else
      return nil
    end
  end
  # SENDGRID CATEGORY STATS
  def sendgrid_get_category_stats(start_date, end_date, aggregate_by, categories)
    logger.debug 'sendgrid_get_category'
    url = URI.parse(SENDGRID_API_URL + 'v3/categories/stats')
    sendgrid_dispatch_get_request(url, _sendgrid_category_get_params(start_date, end_date, aggregate_by, categories))
  end

  def _sendgrid_category_get_params(start_date, _end_date, _aggregate_by, categories)
    {
      'start_date' => start_date,
      # 'end_date' => end_date,
      # 'aggregate_by' => aggregate_by,
      'categories' => categories
    }
  end

  # SENDGRID CATEGORY
  # Single email tracking since they don't do this by default
  def sendgrid_set_marketing_email_category
    sendgrid_create_marketing_email_category(sendgrid_marketing_email_name)
    sendgrid_add_marketing_email_category(sendgrid_marketing_email_name)
  end

  def sendgrid_create_marketing_email_category(category_name)
    logger.debug 'sendgrid_create_marketing_email_category'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/category/create.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_category_create_params(category_name))
  end

  def _sendgrid_marketing_email_category_create_params(category_name)
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'category' => category_name
    }
  end

  def sendgrid_add_marketing_email_category(category_name)
    logger.debug 'sendgrid_add_marketing_email_category'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/category/add.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_category_add_params(category_name))
  end

  def _sendgrid_marketing_email_category_add_params(category_name)
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'category' => category_name,
      'name' => sendgrid_marketing_email_name
    }
  end

  def sendgrid_remove_marketing_email_category
    logger.debug 'sendgrid_remove_marketing_email_category'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/category/remove.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_category_remove_params)
  end

  def _sendgrid_marketing_email_category_remove_params
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'category' => sendgrid_marketing_email_name,
      'name' => sendgrid_marketing_email_name
    }
  end

  def sendgrid_list_marketing_email_category
    logger.debug 'sendgrid_list_marketing_email_category'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/category/list.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_category_list_params)
  end

  def _sendgrid_marketing_email_category_list_params
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      # 'category' => sendgrid_marketing_email_name
    }
  end

  # SENDGRID MARKETING EMAIL SCHEDULE
  def sendgrid_add_marketing_email_schedule
    logger.debug 'sendgrid_add_marketing_email_schedule'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/schedule/add.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_schedule_add_params)
  end

  def _sendgrid_marketing_email_schedule_add_params
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'name' => sendgrid_marketing_email_name,
      # 'at' => ,# YYYY-MM-DDTHH:MM:SS+-HH:MM
      'after' => 1, # number of minutes
    }
  end

  def sendgrid_get_marketing_email_schedule
    logger.debug 'sendgrid_get_marketing_email_schedule'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/schedule/get.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_schedule_get_params)
  end

  def sendgrid_delete_marketing_email_schedule
    logger.debug 'sendgrid_add_marketing_email_schedule'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/schedule/delete.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_schedule_get_params)
  end

  def _sendgrid_marketing_email_schedule_get_params
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'name' => sendgrid_marketing_email_name
    }
  end

  # SENDGRID MARKETING EMAIL RECIPIENTS
  def sendgrid_add_marketing_email_recipients
    logger.debug 'sendgrid_add_marketing_email_recipients'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/recipients/add.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_recipients_add_params)
  end

  def _sendgrid_marketing_email_recipients_add_params
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'name' => sendgrid_marketing_email_name,
      'list' => email_list.name
    }
  end

  def sendgrid_get_marketing_email_recipients
    logger.debug 'sendgrid_get_marketing_email_recipients'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/recipients/get.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_recipients_get_params)
  end

  def _sendgrid_marketing_email_recipients_get_params
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'name' => sendgrid_marketing_email_name
    }
  end

  def sendgrid_delete_marketing_email_recipients
    logger.debug 'sendgrid_delete_marketing_email_recipients'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/recipients/delete.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_recipients_delete_params)
  end

  def _sendgrid_marketing_email_recipients_delete_params
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'name' => sendgrid_marketing_email_name,
      'list' => email_list.name
    }
  end

  # SENDGRID MARKETING EMAIL
  def sendgrid_add_marketing_email
    logger.debug 'sendgrid_add_marketing_email'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/add.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_add_params)
  end

  def _sendgrid_marketing_email_add_params
    email_html = html
    email_text = Nokogiri::HTML(email_html).text
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'identity' => sendgrid_identity,
      'name' => sendgrid_marketing_email_name,
      'subject' => subject,
      'html' => email_html,
      'text' => email_text
    }
  end

  def sendgrid_edit_marketing_email
    logger.debug 'sendgrid_edit_marketing_email'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/edit.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_add_params)
  end

  def _sendgrid_marketing_email_edit_params(newname)
    sendgrid_params = _sendgrid_marketing_email_add_params
    sendgrid_params[:newname] = newname
  end

  def sendgrid_get_marketing_email
    logger.debug 'sendgrid_get_marketing_email'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/get.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_get_params)
  end

  def sendgrid_list_marketing_email
    logger.debug 'sendgrid_list_marketing_email'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/list.json')
    sendgrid_dispatch_request(url, _sendgrid_marketing_email_get_params)
  end

  def _sendgrid_marketing_email_get_params
    {
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'name' => sendgrid_marketing_email_name
    }
  end

  def sendgrid_marketing_email_name
    sendgrid_identity + '_marketing_email_' + id.to_s
  end

  # SENDGRID IDENTITY
  def sendgrid_resolve_identity
    logger.debug 'sendgrid_resolve_identity'
    # get identity
    response = sendgrid_get_identity
    # resolve identity
    response_content = JSON.parse(response.body)
    logger.debug 'response_code ' + response.code.to_s
    logger.debug 'response_content: ' + response_content.to_s
    case response.code.to_s
    when '401'
      # create
      return sendgrid_add_identity
    else
      # update
      return sendgrid_edit_identity
    end
  end

  def sendgrid_add_identity
    logger.debug 'sendgrid_add_identity'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/identity/add.json')
    sendgrid_dispatch_request(url, _sendgrid_add_identity_params)
  end

  def sendgrid_edit_identity
    logger.debug 'sendgrid_edit_identity'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/identity/edit.json')
    sendgrid_dispatch_request(url, _sendgrid_edit_identity_params)
  end

  def sendgrid_get_identity
    logger.debug 'sendgrid_get_identity'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/identity/get.json')
    sendgrid_dispatch_request(url, _sendgrid_identity_params)
  end

  # unused but easy enough to fully implement API
  def sendgrid_list_identity
    logger.debug 'sendgrid_list_identity'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/identity/list.json')
    sendgrid_dispatch_request(url, _sendgrid_identity_params)
  end

  # unused but easy enough to fully implement API, may be used later
  def sendgrid_delete_identity
    logger.debug 'sendgrid_delete_identity'
    url = URI.parse(SENDGRID_API_URL + 'api/newsletter/identity/delete.json')
    sendgrid_dispatch_request(url, _sendgrid_identity_params)
  end

  def _sendgrid_add_identity_params
    params = {
      'identity' => sendgrid_identity,
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'name' => from_name,
      'email' => from_address,
      'address' => user.address_1.to_s,
      'city' => user.city.to_s,
      'state' => user.state.to_s,
      'zip' => user.zip_code.to_s,
      'country' => user.country.present? ? user.country.to_s : DEFAULT_COUNTRY
    }
    params['replyto'] = reply_to if reply_to.present?
    params
  end

  def _sendgrid_edit_identity_params
    params = {
      'identity' => sendgrid_identity,
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD,
      'name' => from_name,
      'email' => from_address,
      'address' => user.address_1.to_s
    }
    params['replyto'] = reply_to if reply_to.present?
    params
  end

  def _sendgrid_identity_params
    {
      'identity' => sendgrid_identity,
      'api_user' => SENDGRID_USERNAME,
      'api_key' => SENDGRID_PASSWORD
    }
  end

  def sendgrid_identity
    APP_ID + '_' + user.id.to_s + '-' + id.to_s
  end
end
