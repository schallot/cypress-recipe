action :create do
  install_path = new_resource.application_path

  # Suggested by mongo (https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/)
  cookbook_file '/etc/systemd/system/disable-transparent-hugepages.service' do
    source "disable-transparent-hugepages.service"
  end

  user new_resource.user do
    supports :manage_home => true
    comment "#{new_resource.user} User"
    home "/home/" + new_resource.user
    shell "/bin/bash"
    action :create
  end

  sudo new_resource.user do
    user new_resource.user
    nopasswd true
  end

  apt_repository "mongodb" do
    uri "http://repo.mongodb.org/apt/ubuntu"
    distribution "xenial" + "/mongodb-org/3.4"
    components ["multiverse"]
    keyserver "keyserver.ubuntu.com"
    key "0C49F3730359A14518585931BC711F9BA15703C6"
  end

  # Install dependencies for cypress
  [
    "openssl", "libssl-dev", "libreadline6", "libreadline6-dev",
    "curl", "zlib1g", "zlib1g-dev", "libyaml-dev", "libsqlite3-dev",
    "sqlite3", "libxml2-dev", "libxslt-dev", "autoconf", "libc6-dev",
    "ncurses-dev", "automake", "libtool", "bison", "subversion",
    "pkg-config", "libgmp3-dev", "nodejs", "g++", "nginx"
  ].each do |pkg|
    package pkg do
      action :install
    end
  end

  # Chef doesn't seem to provide a way to specify that the package should
  # both be installed and locked to a version so we're iterating to
  # solve that, this is temporary code anyway until the problems with mongo
  # 3.4.6 are solved.
  [ :install, :lock ].each do |install_action|
    [
      "mongodb-org-mongos", "mongodb-org-server",
      "mongodb-org-shell", "mongodb-org-tools", "mongodb-org"
    ].each do |pkg|
      package pkg do
        action install_action
        version '3.4.5'
      end
    end
  end

  service "disable-transparent-hugepages" do
    action [:start, :enable]
  end

  service "mongod" do
    action [:start, :enable]
  end

  ruby_version = new_resource.ruby_version
  git_repo = new_resource.git_repository
  git_rev = new_resource.git_revision
  username = new_resource.user
  secret_key = new_resource.secret_key
  server_port = new_resource.unicorn_port
  env = new_resource.env_vars.dup

  application install_path do
    owner username
    group username
    environment env
    ruby_runtime install_path do
      version ruby_version
      provider :ruby_build
    end
    ruby_gem 'bundler'
    git install_path do
      user username
      group username
      repository git_repo
      revision git_rev
    end
    bundle_install do
      deployment true
      without %w{development test}
    end
    rails do
      secret_token secret_key
      secrets_mode :yaml
    end
    # Defined in libraries/unicorn_config.rb
    unicorn_config do
      config_path "config/unicorn.rb"
      port server_port
    end
  end

  # For versions of ubuntu using Systemd
  template "/etc/systemd/system/#{new_resource.name}_delayed_worker@.service" do
    source "delayed_worker_systemd.conf.erb"
    mode "644"
    variables({
      :username => new_resource.user,
      :rails_app_path => install_path,
      :rails_env => new_resource.environment
    })
    only_if { new_resource.delayed_job }
  end

  # Setup nginx configuration
  template "/etc/nginx/sites-enabled/default" do
    source "nginx.conf.erb"
    mode "644"
    variables({
      :primary_app_path => install_path,
      :primary_app_port => server_port,
      :install_path => install_path,
      :enable_secondary_app => false
    })
  end

  new_resource.delayed_job_count.times do |worker_num|
    service "#{new_resource.name}_delayed_worker@#{worker_num}" do
      action [:start, :enable]
      only_if { new_resource.delayed_job }
    end
  end

  # Create secrets regeneration script (only happens when generate_secrets_on_restart is true)
  cookbook_file '/opt/regenerate-secrets.sh' do
    source "regenerate-secrets.sh"
    mode "755"
    only_if { new_resource.generate_secrets_on_restart }
  end

  template '/etc/systemd/system/regenerate-secrets.service' do
    source "regenerate-secrets.service.erb"
    variables({
      :service_names => [ install_path.split("/").last ],
      :secrets_paths => [ "#{install_path}/#{new_resource.secrets_path}" ]
    })
    only_if { new_resource.generate_secrets_on_restart }
  end

  service "regenerate-secrets" do
    action [:enable]
    only_if { new_resource.generate_secrets_on_restart }
  end

  service "nginx" do
    action :restart
  end
end
