## About

This recipe is designed to make it easier to deploy cypress quickly.

### What it doesn't do:
- It will not download and import the measure bundle (see section on Importing Measure Bundle below)
- It will not set up proxy settings
- Does not configure networking

## Installation Options
This recipe has been tested to work on Ubuntu 18.04 using the following install method:

### Chef Solo

    sudo apt-get update
    sudo apt-get -y install git-core wget
    wget https://packages.chef.io/files/stable/chefdk/3.2.30/ubuntu/18.04/chefdk_3.2.30-1_amd64.deb
    sudo dpkg -i chefdk_3.2.30-1_amd64.deb
    git clone https://github.com/projectcypress/cypress-recipe.git
    cd cypress-recipe
    git checkout cypress_v6
    berks vendor cookbooks

To install Cypress only run

    sudo chef-client -z -j install_cypress.json

Instructions for importing a bundle can be found [here](https://github.com/projectcypress/cypress/wiki/Cypress-4-Initial-Setup).

## Developing using Test Kitchen

If you wish to stand up a local copy of this recipe for testing, there is a test kitchen script included in this repository. If you have never installed test kitchen before, then you will need to do so along with downloading a few other tools. Please follow the steps below before running the `kitchen test` command from the directory you have this repository cloned into.

1. Install [Vagrant](http://www.vagrantup.com/downloads.html) ">= 1.5.2"
2. Install [Virtualbox](https://www.virtualbox.org/) ">= 4.3.14"
3. Install [ChefDK](https://downloads.chef.io/chefdk) ">= 0.2.0"
4. Run `bundle install` in the root of this repository.

Once those steps are completed, you should be able to execute `bundle exec kitchen test` with no problems.

