require './lib/tasks/required_records'
desc 'init required database records'
task required_records: :environment do
  puts 'Verifying required records'
  required_records
  puts 'done.'
end
