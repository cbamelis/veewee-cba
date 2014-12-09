require File.dirname(__FILE__) + "/../.cfg/linux_family_redhat.rb"

iso = "CentOS-7.0-1406-x86_64-Minimal.iso"

CENTOS_7_MINIMAL = LINUX_FAMILY_REDHAT.merge(
  :os_type_id => 'RedHat_64',
  :iso_file => "CentOS/#{iso}",
  :iso_src => "http://mirror.myip.be/pub/centos/7/isos/x86_64/#{iso}",
  :iso_md5 => 'e3afe3f1121d69c40cc23f0bafa05e5d',
)

