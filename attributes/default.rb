require 'securerandom'

default[:cypress][:cypress_install_path] = '/opt/cypress'
default[:cypress][:cypress_internal_port] = 8000
default[:cypress][:cvu_install_path] = '/opt/cypress-validation-utility'
default[:cypress][:cvu_internal_port] = 8001
default[:cypress][:cvu_external_port] = 8080