## About

This recipe is designed to make it easier to deploy popHealth in a safe way. It enables SSL Encryption by default. While it uses a self signed certificate it is fairly simple to replace this certificate with an actual one. 

### What it doesn't do:
- It will not download and import the measure bundle (see section on Importing Measure Bundle below)
- It will not set up proxy settings
- Does not configure networking 
- Does not create any users

## Installation Options
This recipe can be used to build an instance of popHealth in a couple ways. 

### Chef-Solo
Chef-Solo is branch of Chef that is designed to run only on a local machine. The easiest method of installation is 

    wget -O- https://opscode.com/chef/install.sh > install.sh
    chmod +x install.sh
    sudo ./install.sh

This will install chef-solo and it's supporting libraries. 

From there you will need to download the recipes that this one depends on and zip them up. 
    
    mkdir /tmp/cookbooks
    cd /tmp/cookbooks
    sudo apt-get install -y git
    git clone https://github.com/opscode-cookbooks/build-essential.git
    git clone https://github.com/opscode-cookbooks/dmg.git
    git clone https://github.com/opscode-cookbooks/runit.git
    git clone https://github.com/opscode-cookbooks/windows.git
    git clone https://github.com/opscode-cookbooks/chef_handler.git
    git clone https://github.com/higanworks-cookbooks/mongodb-10gen.git
    git clone https://github.com/opscode-cookbooks/apt.git
    git clone https://github.com/opscode-cookbooks/git.git
    git clone https://github.com/schreiaj/ruby-build-recipe.git ruby-build
    git clone https://github.com/opscode-cookbooks/yum.git
    git clone https://github.com/opscode-cookbooks/fail2ban.git
    git clone https://github.com/opscode-cookbooks/firewall.git
    git clone https://github.com/schreiaj/popHealth-recipe.git popHealth
    cd ..
    tar -cvzf cookbooks.tar.gz cookbooks

After that it's a simple matter of running chef-solo and pointing it at that directory. 

    sudo chef-solo -r /tmp/cookbooks.tar.gz -o "apt,git,ruby-build,mongodb-10gen,popHealth"

This will run and automatically configure popHealth. 

If you need to change some settings, you can specify a node.json file and pass a path to it with the -j flag. An example node.json file is below:

    {
    "popHealth":
        {
                "branch" : "develop"
        }
    }



### Chef-Client

If you have a chef-server set up on your network this recipe makes it fairly simple to deploy an instance of popHealth. Simply add all of the dependencies above as recipes for your chef-server (ask whoever manages your chef-server to do this) and ensure they are uploaded. Then you can bootstrap a node for popHealth using

    knife bootstrap -x [user] --sudo -N popHealth -r "apt,git,ruby-build,mongodb-10gen,popHealth" --no-host-key-verify [IP or FQDN]

You will be prompted for a password (you may also pass a -i with a path to an ssh key) and it will deploy. 

