#
# Cookbook Name:: hostname
# Recipe:: default
#

#node.name = Chef::Config[:node_name]

template "/etc/hosts" do
  source "hosts.erb"
  owner 'root'
  group 'root'
  mode 00644
end

template '/etc/sysconfig/network' do
  source "etc_sysconfig_network.erb"
  owner 'root'
  group 'root'
  mode 00644
end

execute "restart rsyslog service" do
  command "sudo service rsyslog restart"
end
