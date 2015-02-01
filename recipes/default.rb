include_recipe "mongodb::10gen_repo"
include_recipe "mongodb::default"
include_recipe "rvm::system_install"
rvm_default_ruby node[:cypress][:ruby_version]

user_home = "/home/" + node[:cypress][:user]
ruby_version = node[:cypress][:ruby_version]
rails_app_path = user_home + "/cypress"
bundle_gem_path = "/usr/local/rvm/gems/ruby-#{node[:cypress][:ruby_version]}"
install_params = "--deployment --without develop test" if node[:cypress][:environment] == "production"
apache_dir = "/etc/apache2"

user node[:cypress][:user] do
  supports :manage_home => true
  gid "rvm"
  comment "#{node[:cypress][:user]} User"
  home "/home/" + node[:cypress][:user]
  shell "/bin/bash"
  action :create
end

sudo node[:cypress][:user] do
  user node[:cypress][:user]
  nopasswd true
end

rvm_gem "bundler" do
  ruby_string node[:cypress][:ruby_version]
  action :install
end

rvm_gem "chef" do
  ruby_string node[:cypress][:ruby_version]
  action :install
end

%w{openssl libssl-dev libreadline6 libreadline6-dev curl zlib1g zlib1g-dev libyaml-dev libsqlite3-dev sqlite3 libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config libxml2-dev libxslt1-dev unison build-essential}.each do |pkg|
  package pkg do
    action :install
  end
end

# Passenger Dependencies
%w{libcurl4-openssl-dev apache2-mpm-prefork apache2-prefork-dev libapr1-dev libaprutil1-dev}.each do |pkg|
  package pkg do
    action :install
  end
end

rvm_gem "passenger" do
  ruby_string node[:cypress][:ruby_version]
  version node[:cypress][:passenger_version]
  action :install
end

directory rails_app_path do
  owner node[:cypress][:user]
  group node[:cypress][:user]
  mode 0755
  action :create
  recursive true
end

git "clone cypress #{node[:cypress][:branch]}" do
  user node[:cypress][:user]
  repository node[:cypress][:git_repository]
  destination rails_app_path
  revision node[:cypress][:branch]
  action :sync
end

file "#{rails_app_path}/.ruby-version" do
  action :delete
end

directory "/data/db" do
  owner node[:cypress][:user]
  group node[:cypress][:user]
  mode 0755
  action :create
  recursive true
end

rvm_shell "passenger_module" do
  code "passenger-install-apache2-module --auto"
end

# Fixes issue where changing ruby version causes bundler to throw a permissions error.
directory bundle_gem_path do
  mode 0775
end

rvm_shell "run bundle install" do
  cwd rails_app_path
  ruby_string node[:cypress][:ruby_version]
  code "bundle install --path #{bundle_gem_path} #{install_params}"
  user node[:cypress][:user]
  group "rvm"
end

rvm_shell "seed database" do
  cwd rails_app_path
  ruby_string node[:cypress][:ruby_version]
  code "bundle exec rake db:seed RAILS_ENV=#{node[:cypress][:environment]}"
  user node[:cypress][:user]
end

template "#{apache_dir}/sites-available/cypress.conf" do
  source "cypress-sites-available.conf.erb"
  variables({
    :cypress_root => rails_app_path + "/public",
    :cypress_env => node[:cypress][:environment],
    :passenger_ruby => "/usr/local/rvm/wrappers/ruby-#{node[:cypress][:ruby_version]}/ruby"
  })
end

link "#{apache_dir}/sites-enabled/000-default.conf" do
  to "#{apache_dir}/sites-available/cypress.conf"
end

template "#{apache_dir}/mods-available/cypress.conf" do
  source "cypress-mods-available.conf.erb"
  variables({
    :mod_passenger => "/usr/local/rvm/gems/ruby-#{node[:cypress][:ruby_version]}/gems/passenger-#{node[:cypress][:passenger_version]}/buildout/apache2/mod_passenger.so",
    :passenger_root => "/usr/local/rvm/gems/ruby-#{node[:cypress][:ruby_version]}/gems/passenger-#{node[:cypress][:passenger_version]}",
    :passenger_ruby => "/usr/local/rvm/wrappers/ruby-#{node[:cypress][:ruby_version]}/ruby"
  })
end

link "#{apache_dir}/mods-enabled/cypress.conf" do
  to "#{apache_dir}/mods-available/cypress.conf"
end

template "#{apache_dir}/httpd.conf" do
  source "httpd.conf.erb"
  variables({
    :servername => node[:cypress][:servername]
  })
end

template "#{apache_dir}/conf-available/cypress.conf" do
  source "cypress-conf-available.conf.erb"
  action :create_if_missing
  sensitive true
  variables({
    :secret_key_base => SecureRandom.hex(64)
  })
end

link "#{apache_dir}/conf-enabled/cypress.conf" do
  to "#{apache_dir}/conf-available/cypress.conf"
end

rvm_shell "precompile assets" do
  cwd rails_app_path
  ruby_string node[:cypress][:ruby_version]
  code "bundle exec rake assets:precompile RAILS_ENV=#{node[:cypress][:environment]}"
  user node[:cypress][:user]
  only_if { node[:cypress][:environment].eql? "production" }
end

template "#{user_home}/start_delayed_job.sh" do
  source "start_delayed_job.sh.erb"
  owner node[:cypress][:user]
  mode "700"
  variables({
    :cypress_path => rails_app_path,
    :rvm_path => node[:rvm][:root_path],
    :rails_env => node[:cypress][:environment]
  })
end

template "/etc/init/delayed_worker.conf" do
  source "delayed_worker.conf.erb"
  variables({
    :username => node[:cypress][:user],
    :user_path => user_home
  })
end

service "apache2" do
  supports :start => true, :stop => true, :restart => true
  action [:enable, :restart]
end

include_recipe "cypress::cron" if node[:cypress][:enable_cron]
