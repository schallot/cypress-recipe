## About

This recipe is designed to make it easier to deploy cypress quickly.

### What it doesn't do:
- It will not download and import the measure bundle (see section on Importing Measure Bundle below)
- It will not set up proxy settings
- Does not configure networking

## Installation Options
This recipe has been tested to work on Ubuntu 16.04 using the following install method:

### Chef Solo

    sudo apt-get -y install git-core wget
    wget https://packages.chef.io/stable/ubuntu/12.04/chefdk_0.15.16-1_amd64.deb
    sudo dpkg -i chefdk_0.15.16-1_amd64.deb
    git clone https://github.com/projectcypress/cypress-recipe.git
    cd cypress-recipe
    berks vendor cookbooks
    sudo chef-client -z -j node.json

You will then need to follow the instructions provided [here](https://github.com/projectcypress/cypress/wiki/Cypress-3.0.0-Install-Instructions#virtual-machine) in order to import the measure bundle.

## Developing using Test Kitchen

If you wish to stand up a local copy of this recipe for testing, there is a test kitchen script included in this repository. If you have never installed test kitchen before, then you will need to do so along with downloading a few other tools. Please follow the steps below before running the `kitchen test` command from the directory you have this repository cloned into.

1. Install [Vagrant](http://www.vagrantup.com/downloads.html) ">= 1.5.2"
2. Install [Virtualbox](https://www.virtualbox.org/) ">= 4.3.14"
3. Install [ChefDK](http://getchef.com/downloads/chef-dk) ">= 0.2.0"

Once those steps are completed, you should be able to execute `kitchen test` with no problems.

