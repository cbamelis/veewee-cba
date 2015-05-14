require File.dirname(__FILE__) + "/../.cfg/linux_family_debian.rb"

iso = "debian-7.8.0-amd64-netinst.iso"

DEBIAN_7_64BIT_MINIMAL = LINUX_FAMILY_DEBIAN.merge(
  :os_type_id => 'Debian_64',
  :iso_file => "Debian/#{iso}",
  :iso_src => "http://mirror.as35701.net/debian-cd/7.8.0/amd64/iso-cd/#{iso}",
  :iso_md5 => "a91fba5001cf0fbccb44a7ae38c63b6e"
)

