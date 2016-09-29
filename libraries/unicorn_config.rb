module UnicornConfig
  # Subclass the resource.
  class Resource < PoiseApplicationRuby::Resources::Unicorn::Resource
    # Give it a new name so we can find it.
    provides(:unicorn_config)
    # Add a new property. Could do more here.
    property(:port)
    property(:config_path)
  end

  # Subclass the provider.
  class Provider < PoiseApplicationRuby::Resources::Unicorn::Provider
    # Match the name from above.
    provides(:unicorn_config)

    # Set service resource options.
    def service_options(resource)
      super
      # Replace the command from the base class.
      cmd = "unicorn --port #{new_resource.port}"
      if new_resource.config_path and
         ::File.exist?(::File.expand_path(new_resource.config_path, new_resource.path))
        cmd << " --config-file #{::File.expand_path(new_resource.config_path, new_resource.path)}"
      end
      cmd << " #{configru_path}"
      resource.ruby_command(cmd)
    end
  end
end
