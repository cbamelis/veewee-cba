require File.dirname(__FILE__) + "/../.cfg/linux_family_redhat.rb"

arch = "x86_64"
version = "6.6"
iso = "CentOS-#{version}-#{arch}-minimal.iso"

CENTOS_6_6_64BIT_MINIMAL = LINUX_FAMILY_REDHAT.merge(
  :os_type_id => 'RedHat_64',
  :iso_file => "CentOS/#{iso}",
  :iso_src => "http://mirror.nsc.liu.se/centos-store/#{version}/isos/#{arch}/#{iso}",
  :iso_md5 => "eb3c8be6ab668e6d83a118323a789e6c",
)

