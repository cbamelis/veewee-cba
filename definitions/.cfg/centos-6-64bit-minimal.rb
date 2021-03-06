require File.dirname(__FILE__) + "/../.cfg/linux_family_redhat.rb"

arch = "x86_64"
version = "6.7"
iso = "CentOS-#{version}-#{arch}-minimal.iso"

CENTOS_6_64BIT_MINIMAL = LINUX_FAMILY_REDHAT.merge(
  :os_type_id => 'RedHat_64',
  :iso_file => "CentOS/#{iso}",
  :iso_src => "http://mirror.myip.be/pub/centos/#{version}/isos/#{arch}/#{iso}",
  :iso_md5 => "9381a24b8bee2fed0c26896141a64b69",
)

