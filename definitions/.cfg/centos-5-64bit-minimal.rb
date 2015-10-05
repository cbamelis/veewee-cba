require File.dirname(__FILE__) + "/../.cfg/linux_family_redhat.rb"

arch = "x86_64"
version = "5.11"
iso = "CentOS-#{version}-#{arch}-bin-1of9.iso"

CENTOS_5_64BIT_MINIMAL = LINUX_FAMILY_REDHAT.merge(
  :os_type_id => 'RedHat_64',
  :iso_file => "CentOS/#{iso}",
  :iso_src => "http://mirror.myip.be/pub/centos/#{version}/isos/#{arch}/#{iso}",
  :iso_md5 => "8d038271ed185b88956bdf215e606b1c",
)

