require File.dirname(__FILE__) + "/../.cfg/linux_family_debian.rb"

iso = "debian-7.7.0-amd64-netinst.iso"

DEBIAN_7_64BIT_MINIMAL = LINUX_FAMILY_DEBIAN.merge(
  :os_type_id => 'Debian_64',
  :iso_file => "Debian/#{iso}",
  :iso_src => "http://mirror.as35701.net/debian-cd/7.7.0/amd64/iso-cd/#{iso}",
  :iso_md5 => "0b31bccccb048d20b551f70830bb7ad0"
)

