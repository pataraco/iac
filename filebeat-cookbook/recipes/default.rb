#
# Cookbook Name:: filebeat
# Recipe:: default
#

# install SSL logstash Cert to ship logs to ELK server
directory '/etc/pki/tls/certs' do
  owner 'root'
  group 'root'
  mode '00755'
  recursive true
  action :create
end
template '/etc/pki/tls/certs/logstash-forwarder.crt' do
  source "logstash-forwarder.crt.erb"
  owner 'root'
  group 'root'
  mode '00644'
end

# import the Elasticsearch public GPG key into apt
execute 'import Elasticsearch GPG' do
  command "wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -"
end
# create the Beats source list
file '/etc/apt/sources.list.d/beats.list' do
  content 'deb https://packages.elastic.co/beats/apt stable main'
end
# update apt package DB (sudo apt-get update)
execute "apt-get-update-now" do
  command "apt-get update"
end

# Install Filebeat (sudo apt-get install filebeat)
package 'Install Filebeat' do
  package_name 'filebeat'
  action :install
end

# configure Filebeat
template '/etc/filebeat/filebeat.yml' do
  source "filebeat.yml.erb"
  owner 'root'
  group 'root'
  mode '00644'
end

# add Filebeat to rc startup (sudo update-rc.d filebeat defaults 95 10)
execute "enable Filebeat service" do
  command "update-rc.d filebeat defaults 95 10"
end
# and start Filebeat (sudo service filebeat restart)
execute "start Filebeat service" do
  command "service filebeat restart"
end

