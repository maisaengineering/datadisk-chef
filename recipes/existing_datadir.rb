#
# Cookbook Name:: datadisk
# Recipe:: default
#
# Copyright 2014, Milo de Vries
#

# target partition enumeration

data_part = node['datadisk']['datapart']

# target disk enumeration

disks_with_fs = node[:filesystem].to_s.scan(/[sx]v?d[a-z]/)
disks = node[:block_device].to_s.scan(/[sx]v?d[a-z]/)
disk_without_fs = disks - disks_with_fs

# TODO: handle >1 disk without FS
# TODO: handle disk without partition

execute "create temporary mount point" do
        command "mkdir #{data_part}_temp_mountpoint"
        not_if { disk_without_fs.empty? }
end

execute "format target disk" do
        command "mkfs -t ext4 /dev/#{disk_without_fs.join}1"
        not_if { disk_without_fs.empty? }
end

#Create datadir if not present

execute "mkdir #{data_part}" do
       not_if { ::File.directory?("#{data_part}") }
end

#add temporary mount point to fstab

ruby_block "add temp mountpoint to /etc/fstab" do
    block do
        file = Chef::Util::FileEdit.new("/etc/fstab")
        file.insert_line_if_no_match("#{data_part}_temp_mountpoint",
                "/dev/#{disk_without_fs.join}1  #{data_part}_temp_mountpoint    ext4    defaults,nofail    1 1"
        )
        file.write_file
        end
        only_if { ::File.directory?("#{data_part}_temp_mountpoint") }
end

template "/etc/init/datadisk.conf" do
  source "datadisk.conf.erb"
  owner "root"
  action :create
  only_if { ::File.directory?("#{data_part}_temp_mountpoint") }
  variables ({
  	:data_part => node['datadisk']['datapart']
  	})
end

execute "enable single user mode" do
	command "sed -i -e 's/DEFAULT_RUNLEVEL=2/DEFAULT_RUNLEVEL=1/' /etc/init/rc-sysinit.conf"
    only_if { ::File.directory?("#{data_part}_temp_mountpoint") }
end

execute "reboot" do
        only_if { node['datadisk']['doitlive'] }
end

