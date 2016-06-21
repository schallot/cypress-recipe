include_recipe "cypress::install_cypress"
include_recipe "cypress::install_cvu"

template "/etc/nginx/sites-enabled/default" do
  source "nginx.conf.erb"
  mode "644"
  variables({
    :primary_app_path => node[:cypress][:cypress_install_path],
    :primary_app_port => node[:cypress][:cypress_internal_port],
    :enable_secondary_app => true,
    :secondary_app_path => node[:cypress][:cvu_install_path],
    :secondary_app_port => node[:cypress][:cvu_internal_port],
    :secondary_app_ext_port => node[:cypress][:cvu_external_port],
  })
end

service "nginx" do
  action :restart
end