require 'securerandom'

default[:cypress][:user] = "cypress"
default[:cypress][:branch] = "master"
default[:cypress][:ruby_version] = "2.2"
default[:cypress][:cypress_git_repository] = "https://github.com/projectcypress/cypress.git"
default[:cypress][:cvu_git_repository] = "https://github.com/projectcypress/cypress.git"
default[:cypress][:servername] = "localhost"
default[:cypress][:environment] = "production"
default[:cypress][:app_config] = {}
default[:cypress][:cypress_install_path] = '/opt/cypress'
default[:cypress][:cypress_secret_key] = SecureRandom.hex(64)

default[:cypress][:cvu_install_path] = '/opt/cypress-validation-utility'
default[:cypress][:cvu_secret_key] = SecureRandom.hex(64)
default[:cypress][:install_cvu] = false