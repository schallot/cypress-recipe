user_home = "/home/" + node[:cypress][:user]
cvu_app_path = '/opt/cypress-validation-utility'

user node[:cypress][:user] do
  supports :manage_home => true
  comment "#{node[:cypress][:user]} User"
  home "/home/" + node[:cypress][:user]
  shell "/bin/bash"
  action :create
end

sudo node[:cypress][:user] do
  user node[:cypress][:user]
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
  "pkg-config", "libgmp3-dev", "nodejs", "g++", "mongodb-org"
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

application node[:cypress][:cypress_install_path] do
  owner node[:cypress][:user]
  group node[:cypress][:user]
  ruby_runtime node[:cypress][:cypress_install_path] do
    version node[:cypress][:ruby_version]
    provider :ruby_build
  end
  ruby_gem 'bundler'
  git node[:cypress][:cypress_install_path] do
    user node[:cypress][:user]
    group node[:cypress][:user]
    repository node[:cypress][:cypress_git_repository]
  end
  bundle_install do
    deployment true
    without %w{development test}
  end
  rails do
    secret_token node[:cypress][:cypress_secret_key]
    secrets_mode :yaml
  end
  unicorn do
    port 8000
  end
end



# For versions of ubuntu using Systemd
template "/etc/systemd/system/cypress_delayed_worker.service" do
  source "delayed_worker_systemd.conf.erb"
  mode "644"
  variables({
    :username => node[:cypress][:user],
    :rails_app_path => node[:cypress][:cypress_install_path],
    :rails_env => node[:cypress][:environment],
    :devise_key => node[:cypress][:cypress_secret_key]
  })
end

service "delayed_worker" do
  action [:start, :enable]
end
