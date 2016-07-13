cypress_install_app 'cypress' do
  application_path node[:cypress][:cypress_install_path]
  env_vars node[:cypress][:cypress_env_vars]
  unicorn_port node[:cypress][:cypress_internal_port]
end