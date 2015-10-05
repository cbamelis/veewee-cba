require File.dirname(__FILE__) + "/../.cfg/linux_family_debian.rb"

arch = "i386"
version = "7.9.0"
iso = "debian-#{version}-#{arch}-netinst.iso"

DEBIAN_7_32BIT_MINIMAL = LINUX_FAMILY_DEBIAN.merge(
  :os_type_id => 'Debian',
  :iso_file => "Debian/#{iso}",
  :iso_src => "http://cdimage.debian.org/mirror/cdimage/archive/#{version}/#{arch}/iso-cd/#{iso}",
  :iso_md5 => "e101a11ddb31f85acef542df1a49bf57"
)

