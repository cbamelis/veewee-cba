require File.dirname(__FILE__) + "/../.cfg/linux_family_debian.rb"

arch = "i386"
version = "8.2.0"
iso = "debian-#{version}-#{arch}-netinst.iso"

DEBIAN_8_32BIT_MINIMAL = LINUX_FAMILY_DEBIAN.merge(
  :os_type_id => 'Debian',
  :iso_file => "Debian/#{iso}",
  :iso_src => "http://mirror.as35701.net/debian-cd/#{version}/#{arch}/iso-cd/#{iso}",
  :iso_md5 => "28383ea038dc46ebbc78fda1e868a49e"
)

