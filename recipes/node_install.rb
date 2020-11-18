# Copyright:: 2020, Rich Bywater, GNU GENERAL PUBLIC LICENSE.
#
# Build ElkHEM Node

# Required packages

package 'rtl-sdr' do
    action :install
end

package 'python3' do
    action :install
end

package 'python3-pip' do
    action :install
end

package 'git' do
    action :install
end

bash 'install-pip-modules' do
    user 'root'
    code <<-EOH
        pip3 install elasticsearch
    EOH
    action :run
end

# User management

user 'elkhem' do
    comment 'ElkHEM'
    home '/home/elkhem'
    manage_home true
    shell '/bin/bash'
    password 'password'
    action :create
end

bash 'home-perms' do
    user 'root'
    code <<-EOH
      chmod 0700 /home/*
    EOH
    action :run
end

user 'pi' do
    manage_home true
    action :remove
    not_if ' who | grep pi '
end

# Install  / Configure ElkHEM

directory '/opt/elkhem' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

directory '/var/log/elkHomeMonitor' do
    owner 'elkhem'
    group 'adm'
    mode '0755'
    action :create
end

git '/opt/elkhem' do
    repository 'https://github.com/faultloop/elkHomeMonitor.git'
    revision 'master'
    action :sync
end

systemd_unit 'elkhem-collect.service' do
    content <<~EOU
    [Unit]
    Description=Collect electric usage from rtl_fm
    
    [Service]
    Type=Simple
    User=elkhem
    ExecStart=/opt/elkhem/bin/rxElectricUsage
    Restart=always
    EOU
    action [:create, :enable]
end

systemd_unit 'elkhem-monitor.timer' do
    content <<~EOU
    [Unit]
    Description=Run system activity accounting tool every 10 minutes
    
    [Timer]
    OnCalendar=*:00/10
    Persistant=true
    
    [Install]
    WantedBy=timers.target
    EOU
    action [:create, :enable]
end


