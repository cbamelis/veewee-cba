require File.dirname(__FILE__) + "/../.cfg/linux.rb"

LINUX_FAMILY_DEBIAN = LINUX.merge(
  :kickstart_file => "preseed.cfg",
  :boot_cmd_sequence => [
    '<Esc>',
    'install ',
    'preseed/url=http://%IP%:%PORT%/preseed.cfg ',
    'debian-installer=en_US ',
    'auto ',
    'locale=en_US ',
    'kbd-chooser/method=us ',
    'netcfg/get_hostname=%NAME% ',
    'netcfg/get_domain=vagrantup.com ',
    'fb=false ',
    'debconf/frontend=noninteractive ',
    'console-setup/ask_detect=false ',
    'console-keymaps-at/keymap=us ',
    'keyboard-configuration/xkb-keymap=us ',
    '<Enter>'
  ],
)
