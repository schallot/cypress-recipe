# precertification version (cypress+cvu) ENV vars
node.default[:cypress][:cypress_env_vars] =
{
  "AUTO_APPROVE" => "true",
  "IGNORE_ROLES" => "true",
  "ENABLE_DEBUG_FEATURES" => "true",
  "DEFAULT_ROLE" => "",
}

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

# Create secrets regeneration script (only happens when generate_secrets_on_restart is true)
cookbook_file '/opt/regenerate-secrets.sh' do
  source "regenerate-secrets.sh"
  mode "755"
  only_if { node[:cypress][:generate_secrets_on_restart] }
end

template '/etc/systemd/system/regenerate-secrets.service' do
  source "regenerate-secrets.service.erb"
  variables({
    :secrets_paths => [
      "#{node[:cypress][:cypress_install_path]}/config/secrets.yml",
      "#{node[:cypress][:cvu_install_path]}/config/secrets.yml"
    ]
  })
  only_if { node[:cypress][:generate_secrets_on_restart] }
end

service "regenerate-secrets" do
  action [:enable]
  only_if { node[:cypress][:generate_secrets_on_restart] }
end