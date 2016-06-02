# class UserMailer < ActionMailer::Base
class UserMailer < ActionMailer::Base
  default from: EMAIL_DEFAULT_FROM

  def system_message_email(subject, message, recipient = DEFAULT_SYSTEM_EMAIL)
    @message = message
    @subject = t('email_system_message_subject', app_name_email: APP_NAME_EMAIL, app_name_short: APP_NAME_SHORT, app_id: APP_ID, subject: subject.to_s, time: Time.now.to_s)
    mail(to: recipient, subject: @subject)
  end

  def reset_password_email(user, current_language)
    @user = user
    @url  = APP_DOMAIN
    @current_language = current_language
    mail(to: @user.email_address, subject: t('email_reset_password_subject', app_name_email: APP_NAME_EMAIL))
  end

  def user_registration_notification_email(user, current_language)
    @user = user
    @url  = APP_DOMAIN
    @current_language = current_language
    mail(to: REGISTRATION_EMAIL, subject: t('email_user_registration_notification_subject', app_name_email: APP_NAME_EMAIL))
  end

  def user_registration_activation_email(user, current_language)
    @user = user
    @url  = APP_DOMAIN
    @current_language = current_language
    mail(to: @user.email_address, subject: t('email_user_registration_activation_subject', app_name_email: APP_NAME_EMAIL))
  end

  def user_registration_approval_request_email(user, current_language)
    @user = user
    @url  = APP_DOMAIN
    @current_language = current_language
    approver_email = APPROVER_EMAIL_USER || DEFAULT_SYSTEM_EMAIL
    mail(to: approver_email, subject: t('email_user_registration_approval_request_subject', app_name_email: APP_NAME_EMAIL))
  end

  def user_registration_approval_notification_email(user, current_language)
    @user = user
    @url  = APP_DOMAIN
    @current_language = current_language
    mail(to: @user.email_address, subject: t('email_user_registration_approval_notification_subject', app_name_email: APP_NAME_EMAIL))
  end

  def user_activation_successful_email(user, current_language)
    @user = user
    @url  = APP_DOMAIN
    @current_language = current_language
    mail(to: @user.email_address, bcc: REGISTRATION_EMAIL, subject: t('email_user_activation_successful_subject', app_name_email: APP_NAME_EMAIL))
  end

  def dl_cart_email(cart, location, current_language)
    @cart = cart
    @location = location
    @current_language = current_language
    mail(to: @cart.email_address, subject: t('email_dl_cart_subject', app_name_email: APP_NAME_EMAIL))
  end

  def ac_export_email(ac_export, current_language)
    @ac_export = ac_export
    @email_subject = t('email_ac_export_subject', app_name_email: APP_NAME_EMAIL)
    @email_subject = @ac_export.email_subject if @ac_export.email_subject.present?
    @email_body = @ac_export.email_body || ''
    logger.debug 'email_subject: ' + @email_subject
    logger.debug 'email_body: ' + @email_body
    @user = @ac_export.ac_session_history.ac_session.user
    @current_language = current_language
    @email_recipients = @user.email_address
    @email_recipients = @ac_export.email_address if @ac_export.email_address.present?
    if ENABLE_AC_EXPORT_FROM_USER_EMAIL_ADDRESS
      mail(to: @email_recipients, from: @user.email_address, subject: @email_subject)
    else
      mail(to: @email_recipients, subject: @email_subject)
    end
  end

  def ac_export_order_fulfillment_email(ac_export, current_language)
    @ac_export = ac_export
    @current_language = current_language
    @user = @ac_export.ac_session_history.ac_session.user
    @ac_session = @ac_export.ac_session_history.ac_session

    @attributes = @ac_export.ac_session_history.ac_session.ac_session_attributes
    @ac_session_attributes = @user.attributes

    @attributes.each do |att|
      @ac_session_attributes[att.name] = att.value
    end
    logger.debug 'ac_session_attributes====' + @ac_session_attributes.inspect

    ac_export_order_fulfillment_email_to = ORDER_EMAIL
    logger.debug 'ac_export_order_fulfillment_email_to: ' + ac_export_order_fulfillment_email_to
    mail(to: ac_export_order_fulfillment_email_to, subject: t('email_ac_export_order_fulfillment_subject', app_name_email: APP_NAME_EMAIL))
  end

  def ac_export_order_confirmation_email(ac_export, current_language)
    @ac_export = ac_export
    @current_language = current_language
    @user = @ac_export.ac_session_history.ac_session.user
    @ac_session = @ac_export.ac_session_history.ac_session

    @attributes = @ac_export.ac_session_history.ac_session.ac_session_attributes
    @ac_session_attributes = @user.attributes

    @attributes.each do |att|
      @ac_session_attributes[att.name] = att.value
    end
    # logger.debug 'ac_session_attributes====' + @ac_session_attributes.inspect

    mail(to: @user.email_address, subject: t('email_ac_export_order_confirmation_subject', app_name_email: APP_NAME_EMAIL))
  end

  def ac_export_approval_notification_email_approver(ac_export, current_language)
    @ac_export = ac_export
    @current_language = current_language
    @user = @ac_export.ac_session_history.ac_session.user
    @ac_session = @ac_export.ac_session_history.ac_session

    @attributes = @ac_export.ac_session_history.ac_session.ac_session_attributes
    @ac_session_attributes = @user.attributes

    @attributes.each do |att|
      @ac_session_attributes[att.name] = att.value
    end
    # logger.debug 'ac_session_attributes====' + @ac_session_attributes.inspect
    approver_email = APPROVER_EMAIL_ADCREATOR || DEFAULT_SYSTEM_EMAIL
    mail(to: approver_email, subject: t('email_ac_export_approval_notification_approver_subject', app_name_email: APP_NAME_EMAIL))
  end

  def ac_export_approval_notification_email_user(ac_export, status, comments, current_language)
    @ac_export = ac_export
    @status = status
    @comments = comments
    @current_language = current_language
    @user = @ac_export.ac_session_history.ac_session.user
    @ac_session = @ac_export.ac_session_history.ac_session
    @email_recipients = @user.email_address
    @email_recipients = @ac_export.email_address if @ac_export.email_address.present?

    @attributes = @ac_export.ac_session_history.ac_session.ac_session_attributes
    @ac_session_attributes = @user.attributes

    @attributes.each do |att|
      @ac_session_attributes[att.name] = att.value
    end
    # logger.debug 'ac_session_attributes====' + @ac_session_attributes.inspect
    subject = ''
    case status
    when 'submitted'
      subject = t('email_ac_export_approval_notification_user_subject_submitted', app_name_email: APP_NAME_EMAIL)
    when 'approved'
      subject = t('email_ac_export_approval_notification_user_subject_approved', app_name_email: APP_NAME_EMAIL)
    when 'denied'
      subject = t('email_ac_export_approval_notification_user_subject_denied', app_name_email: APP_NAME_EMAIL)
    end
    mail(to: @user.email_address, subject: subject)
  end

  def social_media_post_email(share_link, email_address, description, current_user, current_language, email_subject)
    @share_link = share_link
    @description = description
    @user = current_user
    @current_language = current_language
    subject = email_subject.present? ? email_subject : t('email_social_media_post_subject', app_name_email: APP_NAME_EMAIL)
    if ENABLE_SOCIAL_MEDIA_EMAIL_FROM_USER_EMAIL_ADDRESS
      mail(to: email_address, from: @user.email_address, subject: subject)
    else
      mail(to: email_address, subject: subject)
    end
  end

  def cart_confirmation_email(order, current_language)
    @order = order
    @user = order.user
    @current_language = current_language
    email_address = @user.email_address
    mail(to: email_address, subject: t('email_cart_confirmation_subject', app_name_email: APP_NAME_EMAIL))
  end

  def cart_fulfillment_email(order, fulfillment_method, current_language)
    @order = order
    @user = order.user
    @fulfillment_method = fulfillment_method
    @current_language = current_language
    email_address = @fulfillment_method.email_address
    mail(to: email_address, subject: fulfillment_method.title + ' ' + t('email_cart_fulfillment_subject', app_name_email: APP_NAME_EMAIL, username: @user.username, email_address: @user.email_address))
  end

  def cart_status_update_email(order, subject, current_language)
    @order = order
    @user = order.user
    @current_language = current_language
    subject = t('email_cart_status_update_subject', app_name_email: APP_NAME_EMAIL) unless subject.present?
    email_address = order.fulfillment_method.email_address
    mail(to: email_address, subject: subject)
  end

  def dynamic_form_email(dynamic_form_submission, subject, recipient = DEFAULT_SYSTEM_EMAIL, bcc = DEFAULT_SYSTEM_EMAIL)
    @dynamic_form = dynamic_form_submission.dynamic_form
    @dynamic_form_submission = dynamic_form_submission
    @user = @dynamic_form_submission.user
    mail(to: recipient, bcc: bcc, subject: subject)
  end

  def publish_notification_email(results, recipient = PUBLISH_NOTIFICATION_EMAIL)
    @results = results
    @date = Time.zone.now.to_date
    mail(to: recipient, subject: t('email_publish_notification_subject', date: @date, app_name_proper: APP_NAME_PROPER))
  end

  def publish_soon_notification_email(results, recipient = PUBLISH_NOTIFICATION_EMAIL)
    @results = results
    @date = Time.zone.now.to_date
    mail(to: recipient, subject: t('email_publish_soon_notification_subject', date: @date, app_name_proper: APP_NAME_PROPER))
  end

  def unpublish_soon_notification_email(results, recipient = PUBLISH_NOTIFICATION_EMAIL)
    @results = results
    @date = Time.zone.now.to_date
    mail(to: recipient, subject: t('email_unpublish_soon_notification_subject', date: @date, app_name_proper: APP_NAME_PROPER))
  end

  def inline_email(email_subject, email_body, recipient, from)
    recipients = recipient.split(/[,  ;]/).reject(&:blank?)
    return unless recipients.present?
    opt_outs = []
    opt_outs = OptOut.where(email_address: recipients).pluck(:email_address) if ENABLE_OPT_OUT_ON_ALL_EMAILS
    recipients.each do |to|
      next if opt_outs.include?(to)
      # allow sendgrid compatible variable substitution
      processed_email_body = email_body
      processed_email_body.gsub!('[email]',to)
      mail(from: from, to: to, body: processed_email_body, content_type: 'text/html', subject: email_subject).deliver
    end
    puts 'inline_email'
  end
end
