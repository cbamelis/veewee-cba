require File.dirname(__FILE__) + "/../.cfg/linux_family_debian.rb"

iso = "debian-8.0.0-i386-netinst.iso"

DEBIAN_8_32BIT_MINIMAL = LINUX_FAMILY_DEBIAN.merge(
  :os_type_id => 'Debian',
  :iso_file => "Debian/#{iso}",
  :iso_src => "http://mirror.as35701.net/debian-cd/8.0.0/i386/iso-cd/#{iso}",
  :iso_md5 => "72045f21b78824023ad665c2ef387c26"
)

