# publish_routines
def publish_classes
  %w(DlImage AcImage AcCreatorTemplate)
end

def access_level_admins
  access_level_admin_emails = {}
  AccessLevel.all.each do |access_level|
    access_level_admin_emails[access_level.id] = [] unless access_level_admin_emails[access_level.id].present?
    User.active.where(user_type: %w(superuser admin)).each do |user|
      # everyone admins have to be a superuser or have all access levels
      next if access_level.name == 'everyone' && user.user_type != 'superuser' && user.access_levels.count < AccessLevel.all.count
      access_level_admin_emails[access_level.id] << user.email_address if user.has_access? access_level.id
    end
  end
  access_level_admin_emails
end

def publish_recipients(asset, access_level_admin_emails)
  # need to email all admins for all access_levels for asset
  # need to email all superusers
  current_recipients = []
  current_recipients << PUBLISH_NOTIFICATION_EMAIL unless PUBLISH_NOTIFICATION_EMAIL.nil? || PUBLISH_NOTIFICATION_EMAIL.empty?
  current_recipients << asset.user.present? ? asset.user.email_address : '' if asset.respond_to?('user') && asset.user.present?

  asset.asset_access_levels.pluck(:access_level_id).each do |access_level_id|
    access_level_admin_emails[access_level_id].each do |email_address|
      current_recipients << email_address
    end
  end
  current_recipients
end

def validation_passed(asset)
  return false if asset.class.name == 'AcCreatorTemplate' && !%w(pre-publish processed production unpublished).include?(asset.status)
  true
end

def publish_assets(publish_class = nil)
  access_level_admin_emails = access_level_admins
  publish_assets = {}
  publish_soon_assets = {}
  unpublish_soon_assets = {}

  classes = publish_classes
  classes = [publish_class] if publish_class.present?

  classes.each do |c|
    puts 'Publishing: ' + c.to_s

    # publish/unpublish
    c.constantize.where(expired: false, status: %w(pre-publish production unpublished)).each do |asset|
      next unless validation_passed(asset)
      published = asset.publish
      next unless published.present?

      current_recipients = publish_recipients(asset, access_level_admin_emails)

      current_recipients.uniq.each do |recipient|
        publish_assets[recipient] = { 'production' => [], 'unpublished' => [] } unless publish_assets[recipient].present?
        publish_assets[recipient][asset.status] << { 'id' => asset.id, 'title' => asset.title.to_s, 'owner_email_address' => asset.user.present? ? asset.user.email_address : '', 'class_name' => asset.class.name }
      end
    end

    # range
    tomorrow = Time.zone.now.beginning_of_day + 1.day
    in_60_days = Time.zone.now.beginning_of_day + 60.days
    soon_range = tomorrow..in_60_days

    # publish_soon
    c.constantize.where(expired: false, status: %w(pre-publish production unpublished), publish_at: soon_range).order(publish_at: :asc).each do |asset|
      next unless validation_passed(asset)
      current_recipients = publish_recipients(asset, access_level_admin_emails)
      current_recipients.uniq.each do |recipient|
        publish_soon_assets[recipient] = [] unless publish_soon_assets[recipient].present?
        publish_soon_assets[recipient] << { 'id' => asset.id, 'title' => asset.title.to_s, 'owner_email_address' => asset.user.present? ? asset.user.email_address : '', 'class_name' => asset.class.name, 'date' => asset.publish_at.to_date.to_s }
      end
    end

    # unpublish_soon
    c.constantize.where(expired: false, status: %w(pre-publish production unpublished), unpublish_at: soon_range).order(unpublish_at: :asc).each do |asset|
      next unless validation_passed(asset)
      current_recipients = publish_recipients(asset, access_level_admin_emails)
      current_recipients.uniq.each do |recipient|
        unpublish_soon_assets[recipient] = [] unless unpublish_soon_assets[recipient].present?
        unpublish_soon_assets[recipient] << { 'id' => asset.id, 'title' => asset.title.to_s, 'owner_email_address' => asset.user.present? ? asset.user.email_address : '', 'class_name' => asset.class.name, 'date' => asset.unpublish_at.to_date.to_s }
      end
    end
  end

  puts 'publish_assets ' + publish_assets.to_yaml
  publish_assets.each do |recipient, assets|
    UserMailer.publish_notification_email(assets, recipient).deliver
  end

  puts 'publish_soon_assets: ' + publish_soon_assets.to_yaml
  publish_soon_assets.each do |recipient, assets|
    UserMailer.publish_soon_notification_email(assets, recipient).deliver
  end

  puts 'unpublish_soon_assets ' + unpublish_soon_assets.to_yaml
  unpublish_soon_assets.each do |recipient, assets|
    UserMailer.unpublish_soon_notification_email(assets, recipient).deliver
  end

  # puts user_assets.to_yaml
end

def remove_hung_items(notify_only = false)
  notify_only = true
  uploadable_classes = publish_classes + ['UserUploadedImage']
  uploadable_classes.each do |c|
    puts 'Searching for hung assets: ' + c.to_s
    c.constantize.where(status: %w(processing uploaded)).each do |asset|
      case asset.status
      when 'processing'
        next unless asset.updated_at < Time.zone.now - 1.day
      when 'uploaded'
        next unless asset.updated_at < Time.zone.now - 4.hours
      end
      puts asset.id.to_s + ': ' + asset.title.to_s + ': ' + asset.updated_at.to_s + ': ' + asset.status.to_s
      next if notify_only
      asset.pub_expire
      asset.save
    end
  end
end

# migrate assets to include publish dates
def migrate_publish
  puts '======================================================================================'
  puts APP_ID

  # migrate
  publish_classes.each do |c|
    puts c.to_s
    c.constantize.all.each do |cc|
      cc.migrate_pub_dates
      cc.publish_keywords
      cc.save
    end
    puts "\n"
  end
end
