require File.dirname(__FILE__) + "/../.cfg/linux_family_debian.rb"

iso = "ubuntu-12.04.2-alternate-amd64.iso"

UBUNTU_1204_DESKTOP = LINUX_FAMILY_DEBIAN.merge(
  :cpu_count => "2",
  :memory_size=> "4096",
  :disk_size => "81920",
  :boot_wait => "4",
  :boot_cmd_sequence => [
    '<Esc><Esc><Enter>',
    '/install/vmlinuz noapic ',
    'preseed/url=http://%IP%:%PORT%/preseed.cfg ',
    'debian-installer=en_US ',
    'auto ',
    'locale=en_US ',
    'kbd-chooser/method=us ',
    'hostname=%NAME% ',
    'fb=false ',
    'debconf/frontend=noninteractive ',
    'keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=us keyboard-configuration/variant=us console-setup/ask_detect=false ',
    'initrd=/install/initrd.gz -- <Enter>'  
  ],
  :os_type_id => 'Debian_64',
  :iso_file => "Ubuntu/#{iso}",
  #:iso_src => "http://mirror.as35701.net/debian-cd/7.1.0/amd64/iso-cd/#{iso}",
  #:iso_md5 => "80f498a1f9daa76bc911ae13692e4495"
)

