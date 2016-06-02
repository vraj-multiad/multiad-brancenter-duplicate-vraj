source 'https://rubygems.org'
ruby '2.1.6'

gem 'aes'                                                    # Encrypt oauth tokens
gem 'aws-sdk'                                                # AWS SDK
gem 'bcrypt-ruby', '3.1.2'                                   # Use ActiveModel has_secure_password
gem 'blitline'                                               # Cloud image processing
gem 'carrierwave_direct'                                     # S3 uploads
gem 'coffee-rails', '4.0.0'                                  # Javascript preprocessor
gem 'chosen-rails'                                           # jquery selectbox search
gem 'country_select', github: 'stefanpenner/country_select'  # Country select helper
gem 'factory_girl_rails'                                     # Instead of fixtures
gem 'figaro'                                                 # Application configuration
gem 'foreman', require: false                                # Launch app/workers
gem 'handlebars_assets'                                      # Support handlebars templates in asset pipeline
gem 'htmlentities'                                           # HTML entities
gem 'httpclient'                                             # Refresh Youtube Oauth token
gem 'jquery-rails', '~> 2.3.0'                               # Javascript framework
gem 'jquery-ui-rails', '~> 5.0.0'                            # Javascript framework
gem 'jbuilder', '1.0.2'                                      # Build JSON APIs with ease
gem 'koala', '~> 1.8.0'                                      # Facebook API
gem 'lodash-rails'                                           # Javascript framework
gem 'net-sftp'                                               # SFTP
gem 'newrelic_rpm'                                           # Newrelic agent
gem 'nokogiri', '1.6.0'                                      # Because XML
gem 'omniauth-facebook', '~> 1.4.1'                          # Facebook auth
gem 'omniauth-saml'                                          # SAML
gem 'omniauth-twitter'                                       # Twitter auth
gem 'omniauth-youtube'                                       # Youtube auth
gem 'paper_trail'                                            # Paper Trail auditing
gem 'pg', '0.15.1'                                           # Postgres database
gem 'rails', '4.0.10'                                        # Because rails
gem 'roo'                                                    # Roo for xlsx spreadsheet support
gem 'roo-xls'                                                # Roo for xls spreadsheet support
gem 'roo-google'                                             # Roo for google spreadsheet support
gem 'rubyzip'                                                # Zip
gem 'sass-rails'                                             # Sassy
gem 'sidekiq'                                                # Background processing
gem 'sinatra'                                                # Sidekiq web ui
gem 'tinymce-rails', '~> 4.1.4'                              # WYSIWYG editor
gem 'turbolinks'                                             # Speed up site navigation
gem 'twitter'                                                # Twitter API
gem 'uglifier', '2.1.1'                                      # Javascript compressor
gem 'unf'                                                    # Carrierwave complains without this...?
gem 'unicorn'                                                # Use unicorn as the app server
gem 'youtube_it', github: 'multiadsolutions/youtube_it'      # Youtube API
gem 'zencoder', '~> 2.5.0'                                   # Cloud video processing

group :development do
  gem 'annotate', '2.5.0'        # Annotate ActiveRecord model with table structure
  gem 'better_errors'            # Better errors
  gem 'binding_of_caller'        # Make better_errors more useful
  gem 'coffee-rails-source-maps' # Source maps for coffeescript
  gem 'meta_request'             # Support rails panel
  gem 'rails-erd'                # Generate ERD of data models
  gem 'thin'                     # Application server
  gem 'pry-byebug'
end

group :test do
  gem 'capybara', '>= 2.2.0'        # Integration testing
  gem 'database_cleaner'            # Clean database between tests
  gem 'rb-inotify', '~> 0.9.7'      # 0.9.6 was yanked
  gem 'launchy'                     # Launch browser from test
  gem 'rspec-rails', '> 3.0'        # Specs
  gem 'poltergeist'                 # PhantomJS driver to run JS in capybara
  gem 'rspec-activemodel-mocks'     # Used for testing mailers. Mocks the model
end

group :production do
  gem 'rack-timeout'            # Raise error before timeout of unicorn
  gem 'rails_12factor', '0.0.2' # Because heroku
end

group :development, :test do
  gem 'jasmine-rails'
end

#### Customizations
#
#
