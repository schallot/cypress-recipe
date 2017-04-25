name             'cypress'
maintainer       'MITRE'
maintainer_email 'mokeefe@mitre.org'
license          'All rights reserved'
description      'Installs/Configures Cypress'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'
depends          "application_ruby", "~> 4.0"
depends          "apt",              "~> 6.1"
depends          "git",              "~> 6.0"
depends          "sudo",             "~> 3.3"
depends          "poise-ruby-build", "~> 1.0"
