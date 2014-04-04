#
# Cookbook Name:: datadisk
# Recipe:: default
#
# Copyright 2014, Milo de Vries
#

# target partition enumeration

datadir = node['datadisk']['datapart']

# target disk enumeration

disks_with_fs = node[:filesystem].to_s.scan(/[sx]v?d[a-z]/)
disks = node[:block_device].to_s.scan(/[sx]v?d[a-z]/)
disk_without_fs = disks - disks_with_fs
target_part = "/dev/" + disk_without_fs.join + "1"

# TODO: handle >1 disk without FS
# TODO: handle disk without partition

execute "format target disk" do
  command "mkfs -t ext3 /dev/#{disk_without_fs.join}1"
  not_if { disk_without_fs.empty? || ::File.directory?("#{datadir}") }
end

#Create datadir

execute "mkdir #{datadir}" do
  not_if { ::File.directory?("#{datadir}") }
end

mount datadir do
  device target_part
  action [:mount, :enable]
  fstype "ext3"
  not_if { disk_without_fs.empty? || ::File.directory?("#{datadir}") }
end
