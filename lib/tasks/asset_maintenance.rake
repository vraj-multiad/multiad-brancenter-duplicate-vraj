### Asset maintenance tasks go in here

# reindex_assets (used for init got prior project and reindexing everything due to index development changes)
require './lib/tasks/reindex_assets.rb'
desc 'Reindexing Assets'
task reindex_assets: :environment do
  puts 'Reindexing assets'
  reindex_assets
  puts 'reindexing done.'
end

desc 'Removing empty dl image groups'
task dl_image_group_prune: :environment do
  puts 'Removing empty DlImageGroup'
  DlImageGroup.prune
  puts 'dl_image_group_prune done'
end

require './lib/tasks/publish_routines.rb'
desc 'publish assets' # intended for nightly processing of assets
task publish_assets: :environment do
  puts 'Removing hung items'
  remove_hung_items
  puts 'Publishing assets'
  publish_assets
  puts 'Publishing done'
end

#  publish migration
desc 'Migrating pub_dates'
task migrate_publish: :environment do
  puts 'Migrating pub_dates'
  migrate_publish
  puts 'migration done'
end

# Expire saved ads
require './lib/tasks/saved_ads_maintenance.rb'
desc 'Expiring Saved Ads'
task expire_saved_ads: :environment do
  puts 'Expiring saved ads older than ' + SAVED_AD_DURATION.to_s + ' days'
  expire_saved_ads
end
