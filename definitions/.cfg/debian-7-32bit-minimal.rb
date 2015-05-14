require File.dirname(__FILE__) + "/../.cfg/linux_family_debian.rb"

iso = "debian-7.8.0-i386-netinst.iso"

DEBIAN_7_32BIT_MINIMAL = LINUX_FAMILY_DEBIAN.merge(
  :os_type_id => 'Debian',
  :iso_file => "Debian/#{iso}",
  :iso_src => "http://mirror.as35701.net/debian-cd/7.8.0/i386/iso-cd/#{iso}",
  :iso_md5 => "0d2f88d23a9d5945f5bc0276830c7d2c"
)

