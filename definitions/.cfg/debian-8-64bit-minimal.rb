require File.dirname(__FILE__) + "/../.cfg/linux_family_debian.rb"

iso = "debian-8.0.0-amd64-netinst.iso"

DEBIAN_8_64BIT_MINIMAL = LINUX_FAMILY_DEBIAN.merge(
  :os_type_id => 'Debian_64',
  :iso_file => "Debian/#{iso}",
  :iso_src => "http://mirror.as35701.net/debian-cd/8.0.0/amd64/iso-cd/#{iso}",
  :iso_md5 => "d9209f355449fe13db3963571b1f52d4"
)

