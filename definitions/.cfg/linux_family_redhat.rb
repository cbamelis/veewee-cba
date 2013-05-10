require File.dirname(__FILE__) + "/../.cfg/linux.rb"

LINUX_FAMILY_REDHAT = LINUX.merge(
  :kickstart_file => "ks.cfg",
  :boot_cmd_sequence => [
    '<Tab>',
    ' text',
    ' cdrom',
    ' ks=http://%IP%:%PORT%/ks.cfg',
    '<Enter>',
  ],
)
