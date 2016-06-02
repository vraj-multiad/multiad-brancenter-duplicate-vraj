# == Schema Information
#
# Table name: ac_exports
#
#  id                    :integer          not null, primary key
#  ac_session_history_id :integer
#  email_address         :text
#  format                :text
#  location              :text
#  created_at            :datetime
#  updated_at            :datetime
#  email_subject         :string(255)
#  email_body            :text
#  export_type           :string(255)
#  bleed                 :boolean          default(FALSE)
#  from_name             :string(255)
#  from_address          :string(255)
#  reply_to              :string(255)
#  token                 :string(255)
#

# class AcExport < ActiveRecord::Base
class AcExport < ActiveRecord::Base
  include Tokenable
  belongs_to :ac_session_history
  has_many :marketing_emails
  has_many :order_items
  has_many :operation_queues, as: :operable

  def inline_email?
    return false unless ac_session_history.ac_session.ac_base.present?
    ac_session_history.ac_creator_template.ac_base.ac_steps.order(id: :asc).last.form_data('inline_email') == 'y'
  end

  def marketing_email?
    return false unless ac_session_history.ac_session.ac_base.present?
    ac_session_history.ac_creator_template.ac_base.ac_steps.order(id: :asc).last.form_data('marketing_email') == 'y'
  end

  def approval_required?
    return false unless ac_session_history.ac_session.ac_base.present?
    ac_session_history.ac_session.ac_base.ac_steps.where(title: 'Export').first.form_data('approval') == 'y'
  end

  def approve(comments = '')
    UserMailer.ac_export_approval_notification_email_user(self, 'approved', comments, 'en').deliver
    UserMailer.ac_export_email(self, 'en').deliver
  end

  def deny(comments = '')
    UserMailer.ac_export_approval_notification_email_user(self, 'denied', comments, 'en').deliver
  end

  def thumbnail
    ac_session = ac_session_history.ac_session
    '/sessions/' + APP_ID + '/' + ac_session.id.to_s + '-' + ac_session.current_ac_document_id.to_s + '/thumbnail_1.png'
  end

  def thumbnail_url
    PICKUP_URL + thumbnail
  end

  def download_url
    ac_session = ac_session_history.ac_session
    return PICKUP_URL + '/pickup/' + token + '/' +URI.encode(Pathname.new(location).basename.to_s) if ac_session.ac_creator_template_group_id.present? #direct pdf only
    PICKUP_URL + '/sessions/' + APP_ID + '/' + ac_session.id.to_s + '-' + ac_session.current_ac_document_id.to_s + '/export.zip' if ac_session.current_ac_document_id.present?
  end
end
