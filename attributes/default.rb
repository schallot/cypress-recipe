# ATL Version (cypress only) ENV Vars
default[:cypress][:cypress_env_vars] =
{
  "AUTO_APPROVE" => "false",
  "IGNORE_ROLES" => "false",
  "ENABLE_DEBUG_FEATURES" => "false",
  "DEFAULT_ROLE" => "",
}
default[:cypress][:cypress_internal_port] = 8000
# this is the path which Cypress/CVU/CQM Execution will install itself to,
# not the path you want it to install to! The Cypress package specifies itself
# where it will install to, so you will need to recompile to package
# to change it. The same applies to the cvu_install_path below.
default[:cypress][:cypress_install_path] = '/opt/cypress'
default[:cypress][:cvu_install_path] = '/opt/cypress-validation-utility'
default[:cypress][:cqm_execution_install_path] = '/opt/cqm-execution-service'
default[:cypress][:cypress_repository] = 'https://dl.packager.io/srv/deb/projectcypress/cypress/cypress_v5/ubuntu'
default[:cypress][:cvu_repository] = 'https://dl.packager.io/srv/deb/projectcypress/cypress-validation-utility/cvu_v5/ubuntu'
default[:cypress][:cqm_execution_repository] = 'https://dl.packager.io/srv/deb/projecttacoma/cqm-execution-service/cypress_v5/ubuntu'
default[:cypress][:cypress_repository_key] = 'https://dl.packager.io/srv/projectcypress/cypress/key'
default[:cypress][:cvu_repository_key] = 'https://dl.packager.io/srv/projectcypress/cypress-validation-utility/key'
default[:cypress][:cqm_execution_repository_key] = 'https://dl.packager.io/srv/projecttacoma/cqm-execution-service/key'
# Blank version means latest build, anything else will attempt to install
# a specific version from the repository.
default[:cypress][:cypress_version] = ''
default[:cypress][:cvu_version] = ''
default[:cypress][:cqm_execution_version] = ''
# Do not override the port number unless you know what you are doing! These values are
# hardcoded into the package and changing them will render the app inoperable
default[:cypress][:cvu_internal_port] = 8001
default[:cypress][:cvu_external_port] = 8080
default[:cypress][:generate_secrets_on_restart] = false
