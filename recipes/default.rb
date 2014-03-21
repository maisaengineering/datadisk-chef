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

execute "format target disk" do
        # command "echo #{@@disk_without_fs} > /tmp/target.log"
        command "mkfs -t ext3 /dev/#{disk_without_fs.join}1"
        not_if { disk_without_fs.empty? }
end

execute "create temporary mount point" do
        command "mkdir #{data_part}_temp_mountpoint"
        not_if { disk_without_fs.empty? }
end

#Debugging goes here
execute "echo #{data_part}_temp_mountpoint > /tmp/target.log" do
       only_if { ::File.directory?("#{data_part}_temp_mountpoint/") }
end

#add temporary mount point to fstab

ruby_block "add temp mountpoint to /etc/fstab" do
    block do
        file = Chef::Util::FileEdit.new("/etc/fstab")
        file.insert_line_if_no_match("#{data_part}_temp_mountpoint",
                "/dev/#{disk_without_fs.join}1  #{data_part}_temp_mountpoint    ext3    defaults        1 1"
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

execute "reboot" do
        only_if { node['datadisk']['doitlive'] }
end
