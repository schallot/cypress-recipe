name             'cypress'
maintainer       'MITRE'
maintainer_email 'mokeefe@mitre.org'
license          'All rights reserved'
description      'Installs/Configures Cypress'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'
depends          "application_ruby"
depends          "apt"
depends          "git"
depends          'nginx_passenger'
depends          "sudo"
depends          "poise-ruby-build"