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
        command "mkfs -t ext3 /dev/#{disk_without_fs.join}1"
        not_if { disk_without_fs.empty? }
end

#Create datadir

execute "mkdir #{data_part}" do
       not_if { ::File.directory?("#{data_part}") }
end

#add mount point to fstab

ruby_block "add mountpoint to /etc/fstab" do
    block do
        file = Chef::Util::FileEdit.new("/etc/fstab")
        file.insert_line_if_no_match("#{data_part}",
                "/dev/#{disk_without_fs.join}1  #{data_part}    ext3    defaults,nofail    1 1"
        )
        file.write_file
        end
        only_if { ::File.directory?("#{data_part}") }
end

execute "mount #{data_part}"
