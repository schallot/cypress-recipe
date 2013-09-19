name             'popHealth'
maintainer       'MITRE'
maintainer_email 'aschreiber@mitre.org'
license          'All rights reserved'
description      'Installs/Configures popHealth'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
depends          "mongodb-10gen"
depends          "apt"
depends          "git"
depends          "ruby-build"
depends          "yum"
depends          "fail2ban"
depends          "firewall"
depends          "yum"
