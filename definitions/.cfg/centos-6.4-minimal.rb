require File.dirname(__FILE__) + "/../.cfg/linux_family_redhat.rb"

iso = "CentOS-6.4-x86_64-minimal.iso"

CENTOS_64_MINIMAL = LINUX_FAMILY_REDHAT.merge(
  :os_type_id => 'RedHat_64',
  :iso_file => "CentOS/#{iso}",
  :iso_src => "http://mirror.myip.be/pub/centos/6.4/isos/x86_64/#{iso}",
  :iso_md5 => "4a5fa01c81cc300f4729136e28ebe600",
)

