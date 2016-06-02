# config/initializers/rack_timeout.rb
Rack::Timeout.timeout = 15 if ENV['RAILS_ENV'] == 'production' # seconds  # default is 15
