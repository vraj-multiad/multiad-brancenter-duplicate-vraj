# Enter custom client tasks at the end of file

require './lib/tasks/clear_uploads.rb'
desc 'clear incomplete uploads older than 1 day'
task clear_inprocess_uploads: :environment do
  puts 'Clearing user uploaded images'
  clear_uploads
  puts 'done.'
end

require './lib/tasks/validate_kwikee_assets.rb'
desc 'report kwikee_asset orphans'
task validate_kwikee_assets: :environment do
  puts 'Reporting kwikee_asset orphans'
  validate_kwikee_assets
  puts 'done.'
end

#####################################################
#
# Enter your custom client tasks after this block
#
#####################################################
