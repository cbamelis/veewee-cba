require File.dirname(__FILE__) + "/../.cfg/linux_family_redhat.rb"

iso = "CentOS-5.9-x86_64-bin-1of9.iso"

CENTOS_59_MINIMAL = LINUX_FAMILY_REDHAT.merge(
  :os_type_id => 'RedHat_64',
  :iso_file => "CentOS/#{iso}",
  :iso_src => "http://mirror.myip.be/pub/centos/5.9/isos/x86_64/#{iso}",
  :iso_md5 => "2ee500b9ff3c0e0ac7da83b318962a1e",
)

