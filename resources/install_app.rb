require 'securerandom'

default_action :create

attribute :name, :kind_of => String
attribute :user, :kind_of => String, :default => 'cypress'
attribute :git_repository, :kind_of => String, :default => 'https://github.com/projectcypress/cypress.git'
attribute :ruby_version, :kind_of => String, :default => '2.2'
attribute :secret_key, :kind_of => String, :default => SecureRandom.hex(64)
attribute :unicorn_port, :kind_of => Integer, :default => 8000
attribute :environment, :kind_of => String, :default => "production"
attribute :application_path, :kind_of => String, :default => '/opt/cypress'
attribute :delayed_job, :kind_of => [TrueClass, FalseClass], :default => true