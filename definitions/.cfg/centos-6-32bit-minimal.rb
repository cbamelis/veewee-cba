require File.dirname(__FILE__) + "/../.cfg/linux_family_redhat.rb"

iso = "CentOS-6.6-i386-minimal.iso"

CENTOS_6_32BIT_MINIMAL = LINUX_FAMILY_REDHAT.merge(
  :os_type_id => 'RedHat',
  :iso_file => "CentOS/#{iso}",
  :iso_src => "http://mirror.myip.be/pub/centos/6.6/isos/i386/#{iso}",
  :iso_md5 => "8c14c9a379aa7c7477471938ca06447d",
)

