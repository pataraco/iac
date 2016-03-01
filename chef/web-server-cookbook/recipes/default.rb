#
# Cookbook Name:: web-server
# Recipe:: default
#

# Update the server's repos apt package DB (if more than a day old)
execute "apt-get-update-periodic" do
  command "apt-get update"
  ignore_failure true
  only_if do
    File.exists?('/var/lib/apt/periodic/update-success-stamp') &&
    File.mtime('/var/lib/apt/periodic/update-success-stamp') < Time.now - 86400
  end
end

# Install Nginx
# -------------
# use an Nginx reverse proxy to allow external access.
package 'Install Nginx' do
  package_name 'nginx'
  action :install
end
# set up the service to allow restart
service "nginx" do
  supports :restart => true
end

## F this! it's getting late  ;( just going to hard-code the IP
## get the IP of the app-server
#appsvr = search(:node, "hostname:raco-db-server")
#appsvrip = appsvr["ipaddress"].to_i

# create Nginx default server block and restart Nginx service
#  configures Nginx to direct server's HTTP traffic to Node.js application, listening on raco-app-server:3000
template '/etc/nginx/sites-available/default' do
  source 'nginx-default.erb'
  owner 'root'
  group 'root'
  mode '00644'
## F this! it's getting late  ;( just going to hard-code the IP
#  variables(
#    :appsvrip => appsvrip,
#  )
  notifies :restart, "service[nginx]"
end
