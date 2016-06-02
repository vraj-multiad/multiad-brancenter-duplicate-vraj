# == Schema Information
#
# Table name: dynamic_form_submissions
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  dynamic_form_id :integer
#  token           :string(255)
#  properties      :text
#  recipient       :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class DynamicFormSubmission < ActiveRecord::Base
  include Tokenable

  belongs_to :user
  belongs_to :dynamic_form
  serialize :properties, Hash

  default_scope { order(created_at: :asc) }

  def submit_email
    # UserMailer.dynamic_form_email(self, subject, recipient = DEFAULT_SYSTEM_EMAIL)
    subject = "#{APP_NAME_PROPER} #{dynamic_form.title} submitted by #{user.username} at #{created_at}"
    subject = "(#{APP_ID}) " + subject if Rails.env.development?
    recipient = DEFAULT_DYNAMIC_FORM_EMAIL || DEFAULT_SYSTEM_EMAIL
    bcc = ''
    if dynamic_form.recipient.present?
      bcc += ', ' if bcc.present?
      bcc += recipient
      recipient = dynamic_form.recipient
    end
    if dynamic_form.recipient_field.present? && properties[dynamic_form.recipient_field].present?
      bcc += ', ' if bcc.present?
      bcc += recipient
      recipient = properties[dynamic_form.recipient_field]
    end
    UserMailer.dynamic_form_email(self, subject, recipient, bcc).deliver
  end
end
