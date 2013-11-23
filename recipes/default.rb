include_recipe "mongodb-10gen::single"
include_recipe "rvm::system_install"

user_home = "/home/" + node[:popHealth][:user]
ruby_version = node[:popHealth][:ruby_version]
rails_app_path = user_home + "/popHealth"

user node[:popHealth][:user] do
  supports :manage_home => true
  gid "rvm"
  comment "#{node[:popHealth][:user]} User"
  home "/home/" + node[:popHealth][:user]
  shell "/bin/bash"
  action :create
end

sudo node[:popHealth][:user] do
  user node[:popHealth][:user] 
  nopasswd true
end

rvm_default_ruby node[:popHealth][:ruby_version] do
  action :create
end

rvm_gem "bundler" do
  ruby_string node[:popHealth][:ruby_version]
  action :install
end

rvm_gem "chef" do
  ruby_string node[:popHealth][:ruby_version]
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
  ruby_string node[:popHealth][:ruby_version]
  version node[:popHealth][:passenger_version]
  action :install
end

directory rails_app_path do
  owner node[:popHealth][:user]
  group node[:popHealth][:user]
  mode 0755
  action :create
  recursive true
end

git "clone popHealth #{node[:popHealth][:branch]}" do
  user node[:popHealth][:user]
  repository "https://github.com/pophealth/popHealth.git"
  destination rails_app_path
  revision node[:popHealth][:branch]
  action :sync
end

directory "/data/db" do
  owner node[:popHealth][:user]
  group node[:popHealth][:user]
  mode 0755
  action :create
  recursive true
end

rvm_shell "passenger_module" do
  code "passenger-install-apache2-module --auto"
end

rvm_shell "run bundle install" do 
  cwd rails_app_path
  ruby_string node[:popHealth][:ruby_version]
  code "bundle install --path /usr/local/rvm/gems/ruby-#{node[:popHealth][:ruby_version]}"
  #code "GEM_SPEC_CACHE='#{user_home}/.gem/specs' bundle install"
  user node[:popHealth][:user]
  group "rvm"
end

rvm_shell "seed database" do 
  cwd rails_app_path
  ruby_string node[:popHealth][:ruby_version]
  code "bundle exec rake db:seed RAILS_ENV=production"
  user node[:popHealth][:user]
end

template "/etc/apache2/sites-enabled/000-default" do
  source "pophealth-sites-available.conf.erb"
  variables({
    :pophealth_root => rails_app_path + "/public"
  })
end

template "/etc/apache2/mods-enabled/pophealth.conf" do
  source "pophealth-mods-available.conf.erb"
  variables({
    :mod_passenger => "/usr/local/rvm/gems/ruby-#{node[:popHealth][:ruby_version]}/gems/passenger-#{node[:popHealth][:passenger_version]}/ext/apache2/mod_passenger.so",
    :passenger_root => "/usr/local/rvm/gems/ruby-#{node[:popHealth][:ruby_version]}/gems/passenger-#{node[:popHealth][:passenger_version]}",
    :passenger_ruby => "/usr/local/rvm/wrappers/ruby-#{node[:popHealth][:ruby_version]}/ruby"
  })
end

template "/etc/apache2/httpd.conf" do
  source "httpd.conf.erb"
  variables({
    :servername => node[:popHealth][:servername]
  })
end

rvm_shell "precompile assets" do 
  cwd rails_app_path
  ruby_string node[:popHealth][:ruby_version]
  code "bundle exec rake assets:precompile"
  user node[:popHealth][:user]
end

service "apache2" do
  supports :start => true, :stop => true, :restart => true
  action [:enable, :restart]
end
