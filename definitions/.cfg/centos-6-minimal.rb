require File.dirname(__FILE__) + "/../.cfg/linux_family_redhat.rb"

iso = "CentOS-6.6-x86_64-minimal.iso"

CENTOS_6_MINIMAL = LINUX_FAMILY_REDHAT.merge(
  :os_type_id => 'RedHat_64',
  :iso_file => "CentOS/#{iso}",
  :iso_src => "http://mirror.myip.be/pub/centos/6.6/isos/x86_64/#{iso}",
  :iso_md5 => "eb3c8be6ab668e6d83a118323a789e6c",
)

