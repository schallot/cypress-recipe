provides :pkgr_env, os: "linux", platform_family: "debian"

action :set do
  execute "set_env_#{new_resource.name}" do
    command "#{new_resource.name} config:set #{new_resource.key}=#{new_resource.value}"
  end
end

action :scale do
  execute "scale_env_#{new_resource.name}" do
    command "#{new_resource.name} scale #{new_resource.key}=#{new_resource.value}"
  end
end
