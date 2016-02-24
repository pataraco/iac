#
# Cookbook Name:: mysql
# Recipe:: default
#

mysql_service 'raco' do
  port '3306'
  version '5.5'
  initial_root_password 'MySQLka!'
  action [:create, :start]
end

#mysql_config 'raco' do
#  source 'extra_config_settings.erb'
#  notifies :restart, 'mysql_service[raco]'
#  action :create
#end
