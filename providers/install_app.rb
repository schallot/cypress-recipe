action :create do
  install_path = new_resource.application_path

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
    distribution node['lsb']['codename'] + "/mongodb-org/3.2"
    components ["multiverse"]
    keyserver "keyserver.ubuntu.com"
    key "EA312927"
  end

  # Install dependencies for cypress
  [
    "openssl", "libssl-dev", "libreadline6", "libreadline6-dev",
    "curl", "zlib1g", "zlib1g-dev", "libyaml-dev", "libsqlite3-dev",
    "sqlite3", "libxml2-dev", "libxslt-dev", "autoconf", "libc6-dev",
    "ncurses-dev", "automake", "libtool", "bison", "subversion",
    "pkg-config", "libgmp3-dev", "nodejs", "g++", "mongodb-org", "nginx"
  ].each do |pkg|
    package pkg do
      action :install
    end
  end

  # Mongodb packages do not contain a systemd init script,
  # which is required on new versions of ubuntu. We add one manually
  # in order to fix this issue. It may be safe to remove this at a
  # later time.
  cookbook_file '/etc/systemd/system/mongod.service' do
    source "mongod.service"
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
    unicorn do
      port server_port
    end
  end

  # For versions of ubuntu using Systemd
  template "/etc/systemd/system/#{new_resource.name}_delayed_worker.service" do
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
      :enable_secondary_app => false,
    })
  end

  service "#{new_resource.name}_delayed_worker" do
    action [:start, :enable]
    only_if { new_resource.delayed_job }
  end

  service "nginx" do
    action :restart
  end
end