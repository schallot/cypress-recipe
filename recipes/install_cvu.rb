cypress_install_app 'cypress-validation-utility' do
  application_path node[:cypress][:cvu_install_path]
  application_version node[:cypress][:cvu_version]
  repository node[:cypress][:cvu_repository]
  repository_key node[:cypress][:cvu_repository_key]
  delayed_job_count 0
  unicorn_port node[:cypress][:cvu_internal_port]
  generate_secrets_on_restart node[:cypress][:generate_secrets_on_restart]
end
