cookbook_dir = run_context.cookbook_collection[cookbook_name].root_dir
local_cookbook_dir = "/var/chef/cookbooks"
chef_root = "/etc/chef"
json_file = "dna.json"

# If this is run on chef server then cookbook_dir will be nil, since chef server provides the same functionality
# of this recipe then there is no need to enable this functionality on chef server.
if !cookbook_dir.nil?
  directory chef_root do
    action :create
  end

  # Copy cookbooks to new location if they are not already in the local cookbook directory
  bash "copy cookbooks" do
    code "cp -r #{cookbook_dir}/.. #{local_cookbook_dir}"
    not_if Dir.open(cookbook_dir).path.eql? local_cookbook_dir
  end

  template "#{chef_root}/#{json_file}" do
    source "dna.json.erb"
    variables({
      :run_list => node.run_list.to_json,
      :overrides => node[:popHealth].to_json
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
end