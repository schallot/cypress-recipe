default_action :create

attribute :name, :kind_of => String
attribute :unicorn_port, :kind_of => Integer, :default => 8000
attribute :repository, :kind_of => String
attribute :repository_key, :kind_of => String
attribute :application_path, :kind_of => String
attribute :application_version, :kind_of => String
# Set app to run with 1 frontend unicorn worker. Note that
# any setting inside of config/unicorn.rb in the application is
# still respected to 1 web worker is actually 1 web worker with
# 4 worker processes if worker_processes is set to 4, for example.
attribute :frontend_worker_count, :kind_of => Integer, :default => 1
attribute :delayed_job_count, :kind_of => Integer, :default => 3
attribute :env_vars, :kind_of => Hash, :default => {}
attribute :generate_secrets_on_restart, :kind_of => [TrueClass, FalseClass], :default => false
