#
# Cookbook Name:: elk-server
# Recipe:: default
#

# i don't think that i need this
#include_recipe 'apt'
# need to set up htpasswd
include_recipe 'htpasswd'

# Update the server's repos apt package DB (sudo apt-get update)
execute "apt-get-update-periodic" do
  command "apt-get update"
  ignore_failure true
  only_if do
    File.exists?('/var/lib/apt/periodic/update-success-stamp') &&
    File.mtime('/var/lib/apt/periodic/update-success-stamp') < Time.now - 86400
  end
end

# import the Elasticsearch public GPG key into apt
execute 'import Elasticsearch GPG' do
  command "wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -"
end
# create the Elasticsearch source list
file '/etc/apt/sources.list.d/elasticsearch-2.x.list' do
  content 'deb http://packages.elastic.co/elasticsearch/2.x/debian stable main'
end
# Create the Kibana source list:
file '/etc/apt/sources.list.d/kibana-4.4.x.list' do
  content 'deb http://packages.elastic.co/kibana/4.4/debian stable main'
end
# The Logstash package is available from the same repository as Elasticsearch,
# already installed that public key, so just create the Logstash source list:
file '/etc/apt/sources.list.d/logstash-2.2.x.list' do
  content 'deb http://packages.elastic.co/logstash/2.2/debian stable main'
end
# update apt package DB (sudo apt-get update)
execute "apt-get-update-now" do
  command "apt-get update"
end

# Install OpenJDK (sudo apt-get install openjdk-7-jre-headless)
package 'Install OpenJDK' do
  package_name 'openjdk-7-jre-headless'
  action :install
end

# Install Elasticsearch
# ---------------------
# install Elasticsearch (sudo apt-get -y install elasticsearch)
package 'Install Elasticsearch' do
  package_name 'elasticsearch'
  options '-y'
  action :install
end
# create the config file (and make only accessable via localhost) [network.host: localhost]
template '/etc/elasticsearch/elasticsearch.yml' do
  source "elasticsearch.yml.erb"
  owner 'root'
  group 'elasticsearch'
  mode '00750'
end
# add to rc startup (sudo update-rc.d elasticsearch defaults 95 10)
execute "enable elasticsearch service" do
  command "update-rc.d elasticsearch defaults 95 10"
end
# and start Elasticsearch (sudo service elasticsearch restart)
execute "start elasticsearch service" do
  command "service elasticsearch restart"
end

# Install Kibana
# --------------
# Install Kibana (sudo apt-get -y install kibana)
package 'Install Kibana' do
  package_name 'kibana'
  options '-y'
  action :install
end
# create the config - make Kibana only accessible to the localhost [server.host: "localhost"]
template '/opt/kibana/config/kibana.yml' do
  source "kibana.yml.erb"
  owner 'root'
  group 'root'
  mode '00664'
end
# enable Kibana service (sudo update-rc.d kibana defaults 96 9)
execute "enable Kibana service" do
  command "update-rc.d kibana defaults 96 9"
end
# start Kibana service (sudo service kibana start)
execute "start Kibana service" do
  command "service kibana restart"
end

# Install Nginx
# -------------
# use an Nginx reverse proxy to allow external access.
# install Nginx and Apache2-utils: (sudo apt-get install nginx apache2-utils)
package 'Install Nginx' do
  package_name 'nginx'
  action :install
end
package 'Install Apache2-utils' do
  package_name 'apache2-utils'
  action :install
end
service "nginx" do
  supports :restart => true
end
# Use htpasswd to create an admin user, that can access the Kibana web interface:
# $ sudo htpasswd -c /etc/nginx/htpasswd.users kibanaadmin
# Enter a password at the prompt. need this login to access the Kibana web interface.
htpasswd '/etc/nginx/htpasswd.users' do
  user 'kibadmina'
  password 'KibanaKA!'
  action :add
end
# create Nginx default server block and restart Nginx service
#  configures Nginx to direct server's HTTP traffic to the Kibana application, listening on localhost:5601.
#  Also, Nginx will use the htpasswd.users file, that we created earlier, and require basic authentication.
template '/etc/nginx/sites-available/default' do
  source "nginx.erb"
  owner 'root'
  group 'root'
  mode '00644'
  notifies :restart, "service[nginx]"
end

# Install Logstash
# ----------------
# Install Logstash (sudo apt-get install logstash)
package 'Install Logstash' do
  package_name 'logstash'
  action :install
end
# enable Logstash service (sudo update-rc.d logstash defaults 97 8)
execute "enable Logstash service" do
  command "update-rc.d logstash defaults 97 8"
end
# start Logstash service (sudo service logstash start)
execute "start Logstash service" do
  command "service logstash start"
end
# configure Logstash input/output/filters
template '/etc/logstash/conf.d/02-beats-input.conf' do
  source '02-beats-input.conf.erb'
  owner 'root'
  group 'root'
  mode '00644'
end
template '/etc/logstash/conf.d/10-syslog-filter.conf' do
  source '10-syslog-filter.conf.erb'
  owner 'root'
  group 'root'
  mode '00644'
end
template '/etc/logstash/conf.d/30-elasticsearch-output.conf' do
  source '30-elasticsearch-output.conf.erb'
  owner 'root'
  group 'root'
  mode '00644'
end
# restart Logstash service (sudo service logstash start)
execute "restart Logstash service" do
  command "service logstash restart"
end

# install SSL Certs for clients running Filebeat to ship logs to ELK server
directory '/etc/pki/tls/certs' do
  owner 'root'
  group 'root'
  mode '00755'
  recursive true
  action :create
end
directory '/etc/pki/tls/private' do
  owner 'root'
  group 'root'
  mode '00755'
  action :create
end
template '/etc/pki/tls/certs/logstash-forwarder.crt' do
  source "logstash-forwarder.crt.erb"
  owner 'root'
  group 'root'
  mode '00644'
end
template '/etc/pki/tls/private/logstash-forwarder.key' do
  source "logstash-forwarder.key.erb"
  owner 'root'
  group 'root'
  mode '00644'
end
