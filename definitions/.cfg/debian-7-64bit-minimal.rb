require File.dirname(__FILE__) + "/../.cfg/linux_family_debian.rb"

arch = "amd64"
version = "7.9.0"
iso = "debian-#{version}-#{arch}-netinst.iso"

DEBIAN_7_64BIT_MINIMAL = LINUX_FAMILY_DEBIAN.merge(
  :os_type_id => 'Debian_64',
  :iso_file => "Debian/#{iso}",
  :iso_src => "http://cdimage.debian.org/mirror/cdimage/archive/#{version}/#{arch}/iso-cd/#{iso}",
  :iso_md5 => "774d1fc8c5364e63b22242c33a89c1a3"
)

