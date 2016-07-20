cypress_install_app 'cypress' do
  application_path node[:cypress][:cypress_install_path]
  env_vars node[:cypress][:cypress_env_vars]
  git_revision node[:cypress][:cypress_git_revision]
  unicorn_port node[:cypress][:cypress_internal_port]
  generate_secrets_on_restart node[:cypress][:generate_secrets_on_restart]
end