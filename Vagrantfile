# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Install required plugins
  plugins = ['vagrant-omnibus', "vagrant-berkshelf --plugin-version '2.0.0.rc3'"]
  # Vagrant does not detect new plugins right away. In order to get around this, if we 
  # have added any plugins then we simply set reload to true and tell the user to re-run
  # the vagrant command.
  reload = false
  plugins.each do |plugin|
    # Split so that we can specify plugin versions in the plugins array without breaking the script
    if !Vagrant.has_plugin?(plugin.split("--").first.strip)
      reload = true
      puts "Installing #{plugin}..."
      print %x(vagrant plugin install #{plugin})
      if !$?.success?
        puts "Plugin installation failed. Please fix any errors above and try again."
        exit
      end
    end 
  end
  if reload
    puts "Done installing plugins, however they cannot be accessed until the vagrant command is re-run."
    puts "Please re-run your vagrant command..."
    exit
  end
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise64-base"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: 80, host: 8080, auto_correct: true
  config.vm.network :forwarded_port, guest: 443, host: 4343, auto_correct: true

  # Install the latest version of Chef (uses https://github.com/schisamo/vagrant-omnibus)
  config.omnibus.chef_version = :latest

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  # # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, 
      "--memory", "2048",
      "--cpus", "2"
    ]
  end
  
  # The path to the Berksfile to use with Vagrant Berkshelf
  # config.berkshelf.berksfile_path = "./Berksfile"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  # Plugin must be installed from 
  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    # If you want to override attributes, you can do so by uncommenting the following lines.
    #
    # chef.json = {
    #     "popHealth" => {
    #         "environment" => "development"
    #     }
    # }
    chef.cookbooks_path = "."
    chef.run_list = [
        "recipe[apt]", "recipe[git]", "recipe[popHealth::default]", "recipe[popHealth::cron]"
    ]
  end
end
