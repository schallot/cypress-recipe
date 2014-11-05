name             'cypress'
maintainer       'MITRE'
maintainer_email 'mokeefe@mitre.org'
license          'All rights reserved'
description      'Installs/Configures Cypress'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.0'
depends          "mongodb"
depends          "apt"
depends          "git"
depends          "rvm"
depends          "sudo"