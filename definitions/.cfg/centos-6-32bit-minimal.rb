require File.dirname(__FILE__) + "/../.cfg/linux_family_redhat.rb"

arch = "i386"
version = "6.7"
iso = "CentOS-#{version}-#{arch}-minimal.iso"

CENTOS_6_32BIT_MINIMAL = LINUX_FAMILY_REDHAT.merge(
  :os_type_id => 'RedHat',
  :iso_file => "CentOS/#{iso}",
  :iso_src => "http://mirror.myip.be/pub/centos/#{version}/isos/#{arch}/#{iso}",
  :iso_md5 => "fd2446e4555fb7e8e7e98e21395eae32",
)

