name             'cypress'
maintainer       'MITRE'
maintainer_email 'mokeefe@mitre.org'
license          'All rights reserved'
description      'Installs/Configures Cypress'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'
depends          "application_ruby", "~> 4.0"
depends          "apt",              "~> 4.0"
depends          "git",              "~> 4.6"
depends          'nginx_passenger',  "~> 0.5.7"
depends          "sudo",             "~> 2.11"
depends          "poise-ruby-build", "~> 1.0"