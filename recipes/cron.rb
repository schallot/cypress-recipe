cookbook_dir = run_context.cookbook_collection[cookbook_name].root_dir
local_cookbook_dir = "/var/chef/cookbooks"
local_roles_dir = "/var/chef/roles"

chef_root = "/etc/chef"
json_file = "dna.json"

# If this is run on chef server then cookbook_dir will be nil, since chef server provides the same functionality
# of this recipe then there is no need to enable this functionality on chef server.
if !cookbook_dir.nil?
  root_cookbook_dir = "#{cookbook_dir}/.."
  root_roles_dir = "#{root_cookbook_dir}/../roles"
  running_from_cron = Pathname.new(root_cookbook_dir).cleanpath.to_s.eql? local_cookbook_dir

  directory chef_root do
    action :create
  end

  # Copy cookbooks to new location if they are not already in the local cookbook directory
  bash "copy cookbooks" do
    code "cp -r #{root_cookbook_dir} #{local_cookbook_dir}"
    not_if { running_from_cron }
  end

  bash "copy roles" do
    code "cp -r #{root_roles_dir} #{local_roles_dir}"
    not_if { running_from_cron || !File.exist?(root_roles_dir)  }
  end

  template "#{chef_root}/#{json_file}" do
    source "dna.json.erb"
    variables({
      :run_list => node.run_list.to_json,
      :overrides => node[:cypress].to_json
    })
  end

  template "#{chef_root}/solo.rb" do
    source "solo.rb.erb"
    variables({
      :json_attribs => "#{chef_root}/#{json_file}"
    })
  end

  cron "register chef-solo to run every hour" do
    minute "0"
    user "root"
    command "sudo chef-solo"
  end

  cron "Run the measure evaluation tests every hour after chef-solo" do
    minute "10"
    user "cypress"
    home "/home/cypress/cypress"
    shell "/bin/bash"
    path "/usr/local/rvm/scripts/rvm"
    command %Q{
      cd /home/cypress/cypress &&
      bundle exec rake measure_evaluation_validator:cleanup RAILS_ENV=production &&
      bundle exec rake measure_evaluation_validator:evaluate_all[,5,5] RAILS_ENV=production
    }
  end
end
