require File.dirname(__FILE__) + "/../.cfg/linux_family_debian.rb"

iso = "ubuntu-12.04.5-server-amd64.iso"

UBUNTU_1204_SERVER = LINUX_FAMILY_DEBIAN.merge(
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
    'tasks=server ',
    'initrd=/install/initrd.gz -- <Enter>'  
  ],
  :os_type_id => 'Debian_64',
  :iso_file => "Ubuntu/#{iso}",
  :iso_src => "http://releases.ubuntu.com/12.04/#{iso}",
  :iso_md5 => "769474248a3897f4865817446f9a4a53"
)

