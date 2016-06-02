include ApplicationController

def show_expired_keywords
  Keyword.where("keyword_type like 'unpub%'").each do |k|
    puts k.searchable.expired
  end
end

def prune_expired_keywords
  Keyword.where("keyword_type like 'unpub%'").each do |k|
    if k.searchable.present?
      # puts k.searchable.expired?
    else
      puts 'a = ' + k.searchable_type + '.find(' + k.searchable_id.to_s + ')'
    end
  end
end

def prune_orphaned_keywords
  Keyword.where('searchable_type is null').destroy_all
  Keyword.where('searchable_id is null').destroy_all
  Keyword.all.each do |k|
    k.destroy unless k.searchable.present?
  end
end

def expire_old_assets
  
  expired_assets = []
  Keyword.select(:searchable_type, :searchable_id).where("keyword_type like 'unpub%'").group(:searchable_type, :searchable_id).each do |type, id|
    asset = LoadAsset.load_asset(type: type, id: id)
    expired_assets << asset if asset.present?
  end
  puts expired_assets.to_yaml
end


def find_expired_assets

  expired_assets = []
  Keyword.select(:searchable_type, :searchable_id).where("keyword_type like 'unpub%'").group(:searchable_type, :searchable_id).each do |type, id|
    asset = LoadAsset.load_asset(type: type, id: id)
    expired_assets << asset if asset.present?
  end
  puts expired_assets.to_yaml
end
