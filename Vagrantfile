require 'yaml'

Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/trusty64'

  config.vm.network 'forwarded_port', guest: 5000, host: 3000
  config.vm.network 'private_network', ip: '10.11.12.13'

  config.vm.provider 'virtualbox' do |v|
    v.cpus   = ENV['VAGRANT_CPUS']   || 4
    v.memory = ENV['VAGRANT_MEMORY'] || 1536
  end

  if ENV['VAGRANT_NFS']
    config.vm.synced_folder '.', '/vagrant', type: 'nfs'
  elsif ENV['VAGRANT_RSYNC']
    config.vm.synced_folder '.', '/vagrant', type: 'rsync', rsync__exclude: '.git/'
  end

  # install/update packages
  config.vm.provision 'shell', inline: <<-SCRIPT
    apt-get update && \
    apt-get install -y \
      git \
      libgmp-dev \
      nodejs \
      phantomjs \
      postgresql-9.3 \
      postgresql-server-dev-9.3 \
      redis-server \
      vim
  SCRIPT

  # install rvm/ruby
  config.vm.provision 'shell', privileged: false, inline: <<-SCRIPT
    curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    curl -sSL https://get.rvm.io | bash -s stable --ruby=2.1.6
    . ~/.rvm/scripts/rvm
    gem install bundler
  SCRIPT

  # configure postgres
  db_config = YAML.load_file('config/database.yml')
  %w(development test).each do |env|
    env_config = db_config[env]
    config.vm.provision 'shell', inline: <<-SCRIPT
      sudo -u postgres psql --command "DO \\$body\\$ BEGIN IF NOT EXISTS (SELECT * FROM pg_catalog.pg_user WHERE  usename = '#{env_config['username']}') THEN CREATE USER #{env_config['username']} PASSWORD '#{env_config['password']}'; ALTER USER #{env_config['username']} CREATEDB; END IF; END \\$body\\$;"
    SCRIPT
  end

  # init rails app
  config.vm.provision 'shell', privileged: false, inline: <<-SCRIPT
    cd /vagrant && \
    bundle install && \
    rake db:create && \
    rake db:schema:load
  SCRIPT
end
