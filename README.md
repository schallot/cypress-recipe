## About

This recipe is designed to make it easier to deploy cypress quickly.

### What it doesn't do:
- It will not download and import the measure bundle (see section on Importing Measure Bundle below)
- It will not set up proxy settings
- Does not configure networking

## Installation Options
This recipe has been tested to work on Ubuntu 16.04 using the following install method:

### Chef Solo

    sudo apt-get update
    sudo apt-get -y install git-core wget
    wget https://packages.chef.io/stable/ubuntu/12.04/chefdk_0.15.16-1_amd64.deb
    sudo dpkg -i chefdk_0.15.16-1_amd64.deb
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

You will then need to follow the instructions provided [here](https://github.com/projectcypress/cypress/wiki/Cypress-3.0.0-Install-Instructions#virtual-machine) in order to import the measure bundle for cypress, if you installed the Cypress Validation Utility then you will need to follow the instructions located [here](https://github.com/projectcypress/cypress/wiki/Cypress-Validation-Utility-Initial-Setup) to import the bundle for the CVU as well.

## Developing using Test Kitchen

If you wish to stand up a local copy of this recipe for testing, there is a test kitchen script included in this repository. If you have never installed test kitchen before, then you will need to do so along with downloading a few other tools. Please follow the steps below before running the `kitchen test` command from the directory you have this repository cloned into.

1. Install [Vagrant](http://www.vagrantup.com/downloads.html) ">= 1.5.2"
2. Install [Virtualbox](https://www.virtualbox.org/) ">= 4.3.14"
3. Install [ChefDK](http://getchef.com/downloads/chef-dk) ">= 0.2.0"

Once those steps are completed, you should be able to execute `kitchen test` with no problems.

