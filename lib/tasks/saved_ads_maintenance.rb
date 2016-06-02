# saved ad maintenance routines

# expire saved ads
def expire_saved_ads
  expired_ads = {}
  subject = "expired_saved_ads results: #{Time.zone.now}"
  ads = AcSessionHistory.available.where('created_at < ?', Time.now - SAVED_AD_DURATION.days).order(created_at: :asc)
  ads.each do |expired_ad|
    expired_ads[expired_ad.ac_session.user.email_address] = [] unless expired_ads[expired_ad.ac_session.user.email_address].present?
    expired_ads[expired_ad.ac_session.user.email_address] << "  AcSessionHistory.find(#{expired_ad.id}) Name: #{expired_ad.name} Created Date: #{expired_ad.created_at}\n"
    expired_ad.expire!
  end
  system_message = ads.length.to_s + ' ads to expire from ' + expired_ads.keys.length.to_s + " users.\n\n"

  expired_ads.sort.to_h.each do |email_address, details|
    system_message += email_address + "\n" + details.join("\n").to_s
  end
  UserMailer.system_message_email(subject, system_message).deliver
end
