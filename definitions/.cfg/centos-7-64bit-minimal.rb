require File.dirname(__FILE__) + "/../.cfg/linux_family_redhat.rb"

arch = "x86_64"
version = "7"
build = "1503-01"
iso = "CentOS-#{version}-#{arch}-Minimal-#{build}.iso"

CENTOS_7_64BIT_MINIMAL = LINUX_FAMILY_REDHAT.merge(
  :os_type_id => 'RedHat_64',
  :iso_file => "CentOS/#{iso}",
  :iso_src => "http://mirror.myip.be/pub/centos/#{version}/isos/#{arch}/#{iso}",
  :iso_md5 => 'd07ab3e615c66a8b2e9a50f4852e6a77',
)

