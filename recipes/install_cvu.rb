cypress_install_app 'cypress-validation-utility' do
  application_path node[:cypress][:cvu_install_path]
  git_repository 'https://github.com/projectcypress/cypress-validation-utility.git'
  git_revision node[:cypress][:cvu_git_revision]
  delayed_job false
  unicorn_port node[:cypress][:cvu_internal_port]
  generate_secrets_on_restart node[:cypress][:generate_secrets_on_restart]
end