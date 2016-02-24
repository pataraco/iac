#
# Cookbook Name:: app-server
# Recipe:: default
#

# Update the server's repos apt package DB (sudo apt-get update)
execute "apt-get-update-periodic" do
  command "apt-get update"
  ignore_failure true
  only_if do
    File.exists?('/var/lib/apt/periodic/update-success-stamp') &&
    File.mtime('/var/lib/apt/periodic/update-success-stamp') < Time.now - 86400
  end
end

# Install git
package 'Install Git' do
  package_name 'git'
  action :install
end

# run in-line bash - this is ugly - sorry - i need to sleep
bash 'install_nodejs_service' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    wget https://nodejs.org/dist/v4.3.1/node-v4.3.1-linux-x64.tar.xz
    mkdir node
    tar xvf node-v4.3.1-linux-x64.tar.xz --strip-components=1 -C ./node
    mkdir node/etc
    echo 'prefix=/usr/local' > node/etc/npmrc
    sudo mv node/ /opt/
    sudo chown -R root: /opt/node
    sudo ln -s /opt/node/bin/node /usr/local/bin/node
    sudo ln -s /opt/node/bin/npm /usr/local/bin/npm
    EOH
  not_if { ::File.exists?('/opt/node/bin/node') }
end

# why stop now? run another in-line bash
bash 'install_run_nodejs_app' do
  user 'root'
  cwd '/home/ubuntu'
  code <<-EOH
    git clone https://github.com/jaustinhughey/hello-world-node-express.git
    sudo npm install pm2 -g
    pm2 start hello-world-node-express/app.js
    sudo su -c "env PATH=$PATH:/opt/node/bin pm2 startup ubuntu -u ubuntu --hp /home/ubuntu"
    EOH
  not_if { ::File.exists?('/home/ubuntu/hello-world-node-express/app.js') }
end
