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

# install/create the web page
template '/var/www/index.html' do
  source 'index.html.erb'
  owner 'root'
  group 'root'
  mode '00644'
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

# create Nginx default server block and restart Nginx service
#  configures Nginx to serve up a HTTP page
template '/etc/nginx/sites-available/default' do
  source 'nginx-default.erb'
  owner 'root'
  group 'root'
  mode '00644'
  notifies :restart, "service[nginx]"
end
