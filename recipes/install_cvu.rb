cypress_install_app 'cypress-validation-utility' do
  application_path node[:cypress][:cvu_install_path]
  git_repository 'https://github.com/projectcypress/cypress-validation-utility.git'
  delayed_job false
  unicorn_port node[:cypress][:cvu_internal_port]
end