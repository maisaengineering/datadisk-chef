#
# Cookbook Name:: datadisk
# Recipe:: default
#
# Copyright 2014, Milo de Vries
#

# target partition enumeration

data_part = node['datadisk']['datapart']

# nope out if #{data_part} already exists

return if ::File.directory?("#{data_part}")

# target disk enumeration

disks_with_fs = node[:filesystem].to_s.scan(/[sx]v?d[a-z]/)
disks = node[:block_device].to_s.scan(/[sx]v?d[a-z]/)
disk_without_fs = disks - disks_with_fs
target_part = "/dev/" + disk_without_fs.join + "1"

# TODO: handle >1 disk without FS
# TODO: handle disk without partition

execute "format target disk" do
        command "mkfs -t ext3 /dev/#{disk_without_fs.join}1"
        not_if { disk_without_fs.empty? }
end

#Create datadir

execute "mkdir #{data_part}" do
       not_if { ::File.directory?("#{data_part}") }
end

mount node['datadisk']['datapart'] do
	device target_part
	action [:mount, :enable]
	fstype "ext3"
end
