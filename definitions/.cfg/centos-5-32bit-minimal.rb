require File.dirname(__FILE__) + "/../.cfg/linux_family_redhat.rb"

arch = "i386"
version = "5.11"
iso = "CentOS-#{version}-#{arch}-bin-1of8.iso"

CENTOS_5_32BIT_MINIMAL = LINUX_FAMILY_REDHAT.merge(
  :os_type_id => 'RedHat',
  :iso_file => "CentOS/#{iso}",
  :iso_src => "http://mirror.myip.be/pub/centos/#{version}/isos/#{arch}/#{iso}",
  :iso_md5 => "546644c985904a41e63f9260b297455c",
)

