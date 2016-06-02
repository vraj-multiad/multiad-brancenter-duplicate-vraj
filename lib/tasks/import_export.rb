# dl_image_export.rb
require 'csv'

def export(asset_type)
  asset_type, token, system, search, media_type, topic, ac_image_filter, access_level = init_asset_type(asset_type)
  case asset_type
  when 'kwikee_products'
    assets = KwikeeProduct.all.order(:gtin)
  when 'dl_images'
    assets = DlImage.where(expired: false).order(:id)
  when 'ac_images'
    assets = AcImage.where(expired: false).order(:id)
  when 'ac_creator_templates'
    assets = AcCreatorTemplate.where(expired: false).order(:id)
  when 'ac_texts'
    assets = AcText.where(expired: false).order(:id)
  end

  available = "#{Rails.root}/tmp/#{asset_type}_available" + Time.now.strftime('%Y%m%d:%H:%M:%S').to_s + '.csv'
  # expired = "#{Rails.root}/public/dl_images_expired.csv"

  puts 'token: ' + token.to_s
  puts 'system: ' + system.to_s
  puts 'search: ' + search.to_s
  puts 'media_type: ' + media_type.to_s
  puts 'topic: ' + topic.to_s
  puts 'ac_image_filter: ' + ac_image_filter.to_s
  puts 'access_level: ' + access_level.to_s

  headers = %w(asset_type asset_id token name title system keywords media_types topics ac_image_filter access_levels)

  CSV.open(available, 'w') do |writer|
    writer << headers
    assets.each do |asset|
      # next unless dl_image.expired
      writer << export_asset(asset, token, system, search, media_type, topic, ac_image_filter, access_level)
    end
  end
  upload_file(available)
end

def init_asset_type(asset_type)
  system, search, media_type, topic, ac_image_filter, access_level = false
  case asset_type
  when 'kwikee_product', 'kwikee_products', 'KwikeeProduct', 'KwikeeProducts'
    asset_type = 'kwikee_products'
    token = true
    system = true
    search = true
    media_type = true
    topic = true
    access_level = true
  when 'dl_image', 'dl_images', 'DlImage', 'DlImages'
    asset_type = 'dl_images'
    token = true
    system = true
    search = true
    media_type = true
    topic = true
    access_level = true
  when 'ac_image', 'ac_images', 'AcImage', 'AcImages'
    asset_type = 'ac_images'
    token = true
    system = true
    search = true
    ac_image_filter = true
    access_level = true
  when 'ac_creator_template', 'ac_creator_templates', 'AcCreatorTemplate', 'AcCreatorTemplates'
    asset_type = 'ac_creator_templates'
    token = true
    system = true
    search = true
    media_type = true
    topic = true
    access_level = true
  when 'ac_text', 'ac_texts', 'AcText', 'AcTexts'
    asset_type = 'ac_texts'
    token = true
    access_level = true
  else
    fail 'asset_type unsupported: ' + asset_type.to_s
  end
  [asset_type, token, system, search, media_type, topic, ac_image_filter, access_level]
end

def export_asset(asset, token, system, search, media_type, topic, ac_image_filter, access_level)
  keyword_types = {
    'media_type' => %w(media_type pre-media_type unpublished-media_type),
    'topic' => %w(topic pre-topic unpublished-topic),
    'search' => %w(search pre-search unpublished-search),
    'system' => %w(system pre-system unpublished-system),
    'ac_image_filter' => %w(ac_image_filter)
  }
  puts 'system: ' + asset.keywords.where(keyword_type: keyword_types['system']).pluck(:term).join(',').to_s
  [
    asset.class.name,
    asset.id.to_s,
    token ? asset.token.to_s : '',
    asset.name.to_s,
    asset.title.to_s,
    system ? asset.keywords.where(keyword_type: keyword_types['system']).pluck(:term).join(',').to_s : '',
    search ? asset.keywords.where(keyword_type: keyword_types['search']).pluck(:term).join(',').to_s : '',
    media_type ? asset.keywords.where(keyword_type: keyword_types['media_type']).pluck(:term).join(',').to_s : '',
    topic ? asset.keywords.where(keyword_type: keyword_types['topic']).pluck(:term).join(',').to_s : '',
    ac_image_filter ? asset.keywords.where(keyword_type: keyword_types['ac_image_filter']).pluck(:term).join(',').to_s : '',
    access_level ? asset.asset_access_levels.pluck(:access_level_id).join(',').to_s : ''
  ]
end

def parse_delimited_field(field)
  field.split(',').map(&:strip)
end

def import(csv_file)
  data = CSV.read(csv_file, headers: true).map(&:to_hash)
  data.each do |r|
    asset_type = r['asset_type'].strip
    asset_id = r['asset_id'].strip
    token = r['token'].strip
    next unless asset_id.to_i > 0
    case asset_type
    when 'KeywordTerm'
      # asset = KeywordTerm.find(asset_id)
      # load_keyword_term(r, operation)
    when 'AcCreatorTemplate'
      # asset = AcCreatorTemplate.where(id: asset_id, token: token).take
      # next if asset.expired?
      # load_ac_creator_template(r, operation)
    when 'AcImage'
      # asset = AcImage.where(id: asset_id, token: token).take
      # next if asset.expired?
      # load_ac_image(r, operation)
    when 'DlImage'
      asset = DlImage.where(id: asset_id, token: token).take
      next if asset.expired?
      if r['keywords'].present?
        # search
        asset.keywords.search.destroy_all
        keyword_type = asset.status == 'production' ? 'search' : 'pre-search'  # pre-search is defunct
        parse_delimited_field(r['keywords']).each do |keyword_term|
          next unless keyword_term.present?
          create_hash = { term: keyword_term.downcase, keyword_type: keyword_type, searchable_type: asset_type, searchable_id: asset.id }
          k = Keyword.new create_hash
          k.save
        end
      end
      if r['access_levels'].present?
        asset.asset_access_levels.destroy_all
        parse_delimited_field(r['access_levels']).each do |access_level|
          next unless access_level.to_i > 0
          create_hash = { access_level_id: access_level, restrictable_type: asset.class.name, restrictable_id: asset.id }
          aal = AssetAccessLevel.new create_hash
          aal.save
        end
      end
      if r['media_types'].present?
        # media_types
        asset.media_type.search.destroy_all
        keyword_type = asset.status == 'production' ? 'media_type' : 'pre-media_type'  # pre-media_type is defunct
        parse_delimited_field(r['media_types']).each do |media_type|
          next unless media_type.present?
          create_hash = { term: media_type.downcase, keyword_type: keyword_type, searchable_type: asset_type, searchable_id: asset.id }
          k = Keyword.new create_hash
          k.save
        end
      end
      if r['topics'].present?
        # topics
        asset.media_type.search.destroy_all
        keyword_type = asset.status == 'production' ? 'topic' : 'pre-topic'  # pre-topic is defunct
        parse_delimited_field(r['topics']).each do |topic|
          next unless topic.present?
          create_hash = { term: topic.downcase, keyword_type: keyword_type, searchable_type: asset_type, searchable_id: asset.id }
          k = Keyword.new create_hash
          k.save
        end
      end
      asset.name = r['name'] if r['name'].present?
      asset.title = r['title'] if r['title'].present?
      asset.description = r['description'] if r['description'].present?
      %w(name title description media_types topics keywords access_levels).each do |key|
        next unless r[key].present?
        asset.save
        asset.keywords.system.destroy_all
        # system
        keyword_type = asset.status == 'production' ? 'system' : 'pre-system'  # pre-system is defunct
        if asset.name.present?
          create_hash = { term: asset.name.downcase, keyword_type: keyword_type, searchable_type: asset_type, searchable_id: asset.id }
          k = Keyword.new create_hash
          k.save
        end
        if asset.title.present?
          create_hash = { term: asset.title.downcase, keyword_type: keyword_type, searchable_type: asset_type, searchable_id: asset.id }
          k = Keyword.new create_hash
          k.save
        end
        if asset.description.present?
          create_hash = { term: asset.description.downcase, keyword_type: keyword_type, searchable_type: asset_type, searchable_id: asset.id }
          k = Keyword.new create_hash
          k.save
        end
        break
      end
    when 'KwikeeProduct'
      asset = KwikeeProduct.where(id: asset_id, token: token).take
      if r['keywords'].present?
        # search
        asset.keywords.search.destroy_all
        keyword_type = 'search'
        parse_delimited_field(r['keywords']).each do |keyword_term|
          next unless keyword_term.present?
          create_hash = { term: keyword_term.downcase, keyword_type: keyword_type, searchable_type: asset_type, searchable_id: asset.id }
          k = Keyword.new create_hash
          k.save
        end
      end
      if r['access_levels'].present?
        asset.asset_access_levels.destroy_all
        parse_delimited_field(r['access_levels']).each do |access_level|
          next unless access_level.to_i > 0
          create_hash = { access_level_id: access_level, restrictable_type: asset.class.name, restrictable_id: asset.id }
          aal = AssetAccessLevel.new create_hash
          aal.save
        end
      end
      if r['media_types'].present?
        # media_types
        asset.keywords.media_type.destroy_all
        keyword_type = 'media_type'
        parse_delimited_field(r['media_types']).each do |media_type|
          next unless media_type.present?
          create_hash = { term: media_type.downcase, keyword_type: keyword_type, searchable_type: asset_type, searchable_id: asset.id }
          k = Keyword.new create_hash
          k.save
        end
      end
      if r['topics'].present?
        # topics
        asset.keywords.topic.destroy_all
        keyword_type = 'topic'
        parse_delimited_field(r['topics']).each do |topic|
          next unless topic.present?
          create_hash = { term: topic.downcase, keyword_type: keyword_type, searchable_type: asset_type, searchable_id: asset.id }
          k = Keyword.new create_hash
          k.save
        end
      end
      %w(media_types topics keywords access_levels).each do |key|
        next unless r[key].present?
        asset.save
        break
      end
    else
      puts 'unknown Type: ' + asset_type.to_s
    end
  end
end

def import_file(file_name)
  local_file = "#{Rails.root}/tmp/#{file_name}"
  bucket_name = ENV['AWS_BUCKET_NAME']
  if bucket_name.present?
    if file_name.present?
      s3 = AWS::S3.new
      key = 'import_export/import/' + File.basename(file_name)
      obj = s3.buckets[bucket_name].objects[key]
      if obj.present?
        File.open(local_file, 'wb') do |file|
          obj.read do |chunk|
            file.write(chunk)
          end
        end
        import(local_file)
      else
        fail 'invalid key: ' + key
      end
    else
      fail 'file_name not passed'
    end
  else
    fail 'ENV["AWS_BUCKET_NAME"] not defined'
  end
end

def upload_file(file_name)
  bucket_name = ENV['AWS_BUCKET_NAME']
  if bucket_name.present?
    if file_name.present?
      s3 = AWS::S3.new
      key = 'import_export/export/' + File.basename(file_name)
      s3.buckets[bucket_name].objects[key].write(file: file_name)
      puts "Uploading file #{file_name} to bucket #{bucket_name}."
    else
      fail 'file_name not defined'
    end
  else
    fail 'ENV["AWS_BUCKET_NAME"] not defined'
  end
end

def load_file(file_name)
  local_file = "#{Rails.root}/tmp/#{file_name}"
  bucket_name = ENV['AWS_BUCKET_NAME']

  if bucket_name.present?
    if file_name.present?
      s3 = AWS::S3.new
      key = 'import_export/load/' + File.basename(file_name)
      obj = s3.buckets[bucket_name].objects[key]
      if obj.present?
        File.open(local_file, 'wb') do |file|
          obj.read do |chunk|
            file.write(chunk)
          end
        end
        # import(local_file)
      else
        fail 'invalid key: ' + key
      end
    else
      fail 'file_name not passed'
    end
  else
    fail 'ENV["AWS_BUCKET_NAME"] not defined'
  end
  # return file
  data = CSV.read(local_file, headers: true).map(&:to_hash)
end
