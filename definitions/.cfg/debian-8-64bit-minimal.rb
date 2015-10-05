require File.dirname(__FILE__) + "/../.cfg/linux_family_debian.rb"

arch = "amd64"
version = "8.2.0"
iso = "debian-#{version}-#{arch}-netinst.iso"

DEBIAN_8_64BIT_MINIMAL = LINUX_FAMILY_DEBIAN.merge(
  :os_type_id => 'Debian_64',
  :iso_file => "Debian/#{iso}",
  :iso_src => "http://mirror.as35701.net/debian-cd/#{version}/#{arch}/iso-cd/#{iso}",
  :iso_md5 => "762eb3dfc22f85faf659001ebf270b4f"
)

