require File.dirname(__FILE__) + "/../.cfg/linux_family_debian.rb"

iso = "debian-7.0.0-amd64-netinst.iso"

DEBIAN_7_MINIMAL = LINUX_FAMILY_DEBIAN.merge(
  :os_type_id => 'Debian_64',
  :iso_file => "Debian/#{iso}",
  #:iso_src => "http://mirror.myip.be/pub/centos/6.4/isos/x86_64/#{iso}",
  :iso_md5 => "6a55096340b5b1b7d335d5b559e13ea0",
)

