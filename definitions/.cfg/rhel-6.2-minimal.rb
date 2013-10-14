require File.dirname(__FILE__) + "/../.cfg/linux_family_redhat.rb"

iso = "rhel-server-6.2-x86_64-dvd.iso"

RHEL_62_MINIMAL = LINUX_FAMILY_REDHAT.merge(
  :os_type_id => 'RedHat_64',
  :iso_file => "RHEL/#{iso}",
  #:iso_src => "",
  #:iso_md5 => "",
)

