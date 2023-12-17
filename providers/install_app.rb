action :create do
  install_path = new_resource.application_path

  apt_repository new_resource.name do
    uri new_resource.repository
    distribution "22.04"
    components ["main"]
    key new_resource.repository_key
  end

  # Lock the version to whatever is installed by
  # this Chef recipe in order to require the user
  # to run the upgrade script to upgrade Cypress
  # and also protect the user from accidently
  # upgrading Cypress when they did not intend to
  [ :install, :lock ].each do |install_action|
    package new_resource.name do
      action install_action
      version new_resource.application_version
    end
  end

  # Install the ntp service in order to make sure the time on
  # the server is correct for tests.
  package 'ntp' do
    action :install
  end

  # Set all ENV variables passed in through the env_vars hash
  # for the application
  new_resource.env_vars.each do |key, value|
    cypress_pkgr_env new_resource.name do
      key key
      value value
    end
  end

  # Configure the port which the application should run on
  cypress_pkgr_env new_resource.name do
    key "PORT"
    value new_resource.unicorn_port.to_s
    only_if { new_resource.frontend_worker_count > 0 }
  end

  cypress_pkgr_env new_resource.name do
    key "web"
    value new_resource.frontend_worker_count.to_s
    action :scale
  end

  cypress_pkgr_env new_resource.name do
    key "worker"
    value new_resource.delayed_job_count.to_s
    action :scale
  end

  package 'nginx' do
    action :install
    only_if { new_resource.frontend_worker_count > 0 }
  end

  # Setup nginx configuration
  template "/etc/nginx/sites-enabled/default" do
    source "nginx.conf.erb"
    mode "644"
    variables({
      :primary_app_path => install_path,
      :primary_app_port => new_resource.unicorn_port,
      :enable_secondary_app => false
    })
    only_if { new_resource.frontend_worker_count > 0 }
  end

  template '/etc/systemd/system/regenerate-secrets.service' do
    source "regenerate-secrets.service.erb"
    variables({
      :service_names => [ new_resource.name ]
    })
    only_if { new_resource.generate_secrets_on_restart }
  end

  service "regenerate-secrets" do
    action [:enable]
    only_if { new_resource.generate_secrets_on_restart }
  end

  service "nginx" do
    action :restart
    only_if { new_resource.frontend_worker_count > 0 }
  end

  cookbook_file "/tmp/network.sh" do
    source "network.sh"
    mode 0755
  end
  
  execute "network setup" do
    command "sh /tmp/network.sh"
  end
end
