MySQL Server Cookbook
=====================

The Mysql Server Cookbook uses the Mysql Cookbook that provides resource primitives

Scope
-----
This cookbook is concerned with the "MySQL Community Server"

Requirements
------------
(see Mysql Cookbook)

Platform Support
----------------
(see Mysql Cookbook)

```
|----------------+-----+-----+-----+-----+-----|
| ubuntu-14.04   |     |     | X   | X   |     |
|----------------+-----+-----+-----+-----+-----|
```

Cookbook Dependencies
------------
- mysql
	- yum-mysql-community
	- smf

Usage
-----

You can put extra configuration into the conf.d directory by using the
`mysql_config` resource, like this:

```ruby
mysql_service 'foo' do
  port '3306'
  version '5.5'
  initial_root_password 'change me'
  action [:create, :start]
end

mysql_config 'foo' do
  source 'my_extra_settings.erb'
  notifies :restart, 'mysql_service[foo]'
  action :create
end
```

You are responsible for providing `my_extra_settings.erb` in your own
cookbook's templates folder.

Connecting with the mysql CLI command
-------------------------------------
Logging into the machine and typing `mysql` with no extra arguments
will fail. You need to explicitly connect over the socket with `mysql
-S /var/run/mysql-foo/mysqld.sock`, or over the network with `mysql -h
127.0.0.1`

Upgrading from older version of the mysql cookbook
--------------------------------------------------
- It is strongly recommended that you rebuild the machine from
  scratch. This is easy if you have your `data_dir` on a dedicated
  mount point. If you *must* upgrade in-place, follow the instructions
  below.

- The 6.x series supports multiple service instances on a single
  machine. It dynamically names the support directories and service
  names. `/etc/mysql becomes /etc/mysql-instance_name`. Other support
  directories in `/var` `/run` etc work the same way. Make sure to
  specify the `data_dir` property on the `mysql_service` resource to
  point to the old `/var/lib/mysql` directory.

Resources Overview
------------------
### mysql_service

The `mysql_service` resource manages the basic plumbing needed to get a
MySQL server instance running with minimal configuration.

The `:create` action handles package installation, support
directories, socket files, and other operating system level concerns.
The internal configuration file contains just enough to get the
service up and running, then loads extra configuration from a conf.d
directory. Further configurations are managed with the `mysql_config` resource.

- If the `data_dir` is empty, a database will be initialized, and a
root user will be set up with `initial_root_password`. If this
directory already contains database files, no action will be taken.

The `:start` action starts the service on the machine using the
appropriate provider for the platform. The `:start` action should be
omitted when used in recipes designed to build containers.

#### Example
```ruby
mysql_service 'default' do
  version '5.7'
  bind_address '0.0.0.0'
  port '3306'
  data_dir '/data'
  initial_root_password 'Ch4ng3me'
  action [:create, :start]
end
```

Please note that when using `notifies` or `subscribes`, the resource
to reference is `mysql_service[name]`, not `service[mysql]`.

#### Parameters
(see Mysql Cookbook)

#### Actions
(see Mysql Cookbook)

#### Providers
(see Mysql Cookbook)
