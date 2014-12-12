require File.dirname(__FILE__) + "/../.cfg/linux_family_debian.rb"

iso = "debian-7.7.0-i386-netinst.iso"

DEBIAN_7_32BIT_MINIMAL = LINUX_FAMILY_DEBIAN.merge(
  :os_type_id => 'Debian',
  :iso_file => "Debian/#{iso}",
  :iso_src => "http://mirror.as35701.net/debian-cd/7.7.0/i386/iso-cd/#{iso}",
  :iso_md5 => "76d512c44a9b7eca53ea2812ad5ac36f"
)

