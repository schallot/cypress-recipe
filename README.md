## About

This recipe is designed to make it easier to deploy popHealth quickly.

### What it doesn't do:
- It will not download and import the measure bundle (see section on Importing Measure Bundle below)
- It will not set up proxy settings
- Does not configure networking

## Installation Options
This recipe can be used to build an instance of popHealth in a couple ways. 

### Knife-Solo
Knife-Solo is a tool which wraps the Chef-Solo command and adds some additional functionality normally found in the normal Knife command. This will install Chef on the specified server and then install popHealth and required dependencies. To make this process easier, there is a repository called [popHealth-knife-solo](https://github.com/rbclark/popHealth-knife-solo) which contains the code and instructions in order to do this.

### Chef-Client
If you have a chef-server set up on your network this recipe makes it fairly simple to deploy an instance of popHealth. Simply configure your machine to connect to your chef server, and run the following command in the cookbook directory.

	berks upload

This will upload all dependencies to your chef server. Once this is complete you can run the following command to provision a server.

    knife bootstrap -x [user] --sudo -N popHealth -r "apt,git,popHealth" --no-host-key-verify [IP or FQDN]

You will be prompted for a password (you may also pass a -i with a path to an ssh key) and it will deploy. 

