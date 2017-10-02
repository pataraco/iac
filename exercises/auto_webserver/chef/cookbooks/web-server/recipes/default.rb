#
# Cookbook Name:: web-server
# Recipe:: default
#

# create the parent directory for the website
directory '/var/www/html' do
  owner 'root'
  group 'root'
  mode '00755'
  recursive true
end

# install/create the web page
template '/var/www/html/index.html' do
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

# create the parent directory for nginx
directory '/etc/nginx/sites-available' do
  owner 'root'
  group 'root'
  mode '00755'
  recursive true
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

# install/create the web page
#   going to "cheat" and install the index.html where
#   nginx is configured to serve it from 
template '/usr/share/nginx/html/index.html' do
  source 'index.html.erb'
  owner 'root'
  group 'root'
  mode '00644'
end

