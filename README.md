[![GitHub version](https://badge.fury.io/gh/projectcypress%2Fcypress-recipe.svg)](https://badge.fury.io/gh/projectcypress%2Fcypress-recipe)

## About

This repository includes a Chef recipe for deploying [Cypress](https://www.healthit.gov/cypress/).

### What it doesn't do:
- It will not download and import the measure bundle (see section on Importing Measure Bundle below)
- It will not set up proxy settings
- Does not configure networking

## Installation Options
This recipe has been tested to work on Ubuntu 16.04 using the following install method:

### Chef Solo

    sudo apt-get update
    sudo apt-get -y install git-core wget
    wget https://packages.chef.io/files/stable/chefdk/3.9.0/ubuntu/16.04/chefdk_3.9.0-1_amd64.deb
    sudo dpkg -i chefdk_3.9.0-1_amd64.deb
    git clone https://github.com/projectcypress/cypress-recipe.git
    cd cypress-recipe
    berks vendor cookbooks

You will now need to decide between whether you want to install cypress and the cypress validation utility, only cypress, or only the cypress validation utility.

To install Cypress + Cypress Validation Utility run

    sudo chef-client -z -j install_cypress_cvu.json

To install Cypress only run

    sudo chef-client -z -j install_cypress.json

To install the Cypress Validation Utility only run

    sudo chef-client -z -j install_cvu.json

If you need to install both cypress and the cypress validation utility, make sure you run the first command, attempting to run the second and third installation commands in conjunction will not work properly.

Instructions for importing a bundle can be found [here](https://github.com/projectcypress/cypress/wiki/Cypress-4-Initial-Setup).

## Developing using Test Kitchen

If you wish to stand up a local copy of this recipe for testing, there is a test kitchen script included in this repository. If you have never installed test kitchen before, then you will need to do so along with downloading a few other tools. Please follow the steps below before running the `kitchen test` command from the directory you have this repository cloned into.

1. Install [Vagrant](http://www.vagrantup.com/downloads.html) ">= 1.5.2"
2. Install [Virtualbox](https://www.virtualbox.org/) ">= 4.3.14"
3. Install [ChefDK](https://downloads.chef.io/chefdk) ">= 0.2.0"
4. Run `bundle install` in the root of this repository.

Once those steps are completed, you should be able to execute `bundle exec kitchen test` with no problems.

## License

Copyright 2013 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
