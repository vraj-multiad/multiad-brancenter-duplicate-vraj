# required_records
def required_records
  # access_levels
  system_contacts = User.find_by(username: 'SYSTEM CONTACTS')
  unless system_contacts.present?
    system_contacts = User.new(username: 'SYSTEM CONTACTS', first_name: 'system_contacts', last_name: 'system_contacts', company_name: 'system_contacts', address_1: 'system_contacts', address_2: 'system_contacts', title: 'system_contacts', city: 'system_contacts', state: 'system_contacts', zip_code: 'system_contacts', country: 'US', phone_number: '555-555-5555', fax_number: '555-555-5555', mobile_number: '555-555-5555', website: '555-555-5555', email_address: 'system_contacts@multiad.com', activated: true)
    password = SecureRandom.urlsafe_base64(nil, false)
    system_contacts.password = password
    system_contacts.password_confirmation = password
    system_contacts.token = ''
    system_contacts.save
    puts 'system_contacts.errors.messages: ' + system_contacts.errors.messages.inspect.to_s
  end
  puts system_contacts.inspect

  # access_levels
  ac_e = AccessLevel.find_by(name: 'everyone')
  ac_e = AccessLevel.find_or_create_by(name: 'everyone', title: 'Everyone') unless ac_e.present?
  puts ac_e.inspect

  # languages
  l_en = Language.find_by(name: 'en')
  l_en = Language.find_or_create_by(name: 'en', title: 'English') unless l_en.present?
  puts l_en.inspect

  # roles
  r_d = Role.find_by(name: 'default')
  r_d = Role.find_or_create_by(name: 'default', title: 'Default', default_flag: true, language_id: l_en.id) unless r_d.present?
  puts r_d.inspect
  r_d.access_levels << ac_e unless r_d.access_levels.present? && r_d.access_levels.find(ac_e.id).present?
  puts r_d.access_levels.find(ac_e.id).inspect

  # ac_text
  text1 = AcText.find_by(name: 'replace_all')
  text1 = AcText.find_or_create_by(name: 'replace_all', title: 'Replace Text', creator: '__text__', html: '__text__') unless text1.present?
  puts text1.inspect
  unless text1.asset_access_levels.where(access_level_id: ac_e.id).present?
    create_hash = { access_level_id: ac_e.id, restrictable_type: 'AcText', restrictable_id: text1.id }
    aal = AssetAccessLevel.new create_hash
    aal.save
    puts aal.inspect
  end

  text1 = AcText.find_by(name: 'empty')
  text1 = AcText.find_or_create_by(name: 'empty', title: 'empty', creator: '', html: '') unless text1.present?
  puts text1.inspect
  unless text1.asset_access_levels.where(access_level_id: ac_e.id).present?
    create_hash = { access_level_id: ac_e.id, restrictable_type: 'AcText', restrictable_id: text1.id }
    aal = AssetAccessLevel.new create_hash
    aal.save
    puts aal.inspect
  end

  # keyword_types
  search = KeywordType.find_by(name: 'search')
  search = KeywordType.find_or_create_by(name: 'search', title: 'Search', label: 'Search Keywords') unless search.present?
  puts search.inspect

  ac_image_filter = KeywordType.find_by(name: 'ac_image_filter')
  ac_image_filter = KeywordType.find_or_create_by(name: 'ac_image_filter', title: 'AdCreator Image Filter', label: 'AdCreator Image Filters') unless ac_image_filter.present?
  puts ac_image_filter.inspect

  media_type = KeywordType.find_by(name: 'media_type')
  media_type = KeywordType.find_or_create_by(name: 'media_type', title: 'Media Type', label: 'Media Type Filters') unless media_type.present?
  puts media_type.inspect

  topic = KeywordType.find_by(name: 'topic')
  topic = KeywordType.find_or_create_by(name: 'topic', title: 'Topic', label: 'Topic Filters') unless topic.present?
  puts topic.inspect

  # contact_types
  ct_d = ContactType.find_by(name: 'default')
  ct_d = ContactType.find_or_create_by(name: 'default', title: 'Default') unless ct_d.present?
  puts ct_d.inspect
end

# Custom routines for account sync go here.
#
#
#
#
#
