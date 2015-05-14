require File.dirname(__FILE__) + "/../.cfg/linux_family_redhat.rb"

iso = "CentOS-7-x86_64-Minimal-1503-01.iso"

CENTOS_7_64BIT_MINIMAL = LINUX_FAMILY_REDHAT.merge(
  :os_type_id => 'RedHat_64',
  :iso_file => "CentOS/#{iso}",
  :iso_src => "http://mirror.myip.be/pub/centos/7/isos/x86_64/#{iso}",
  :iso_md5 => 'd07ab3e615c66a8b2e9a50f4852e6a77',
)

