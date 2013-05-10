scripts = "/../.scripts"

LINUX = {
  :cpu_count => "1",
  :memory_size=> "1024",
  :disk_size => "20480",
  :disk_format => "VDI",
  :hostiocache => "on",

  :boot_wait => "5",
  :iso_download_timeout => "10000",
  :kickstart_timeout => "10000",
  :postinstall_timeout => "10000",
  :ssh_login_timeout => "10000",

  :ssh_password => "veewee",
  :ssh_user => "veewee",
  :ssh_key => "",

  :kickstart_port => "7122",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p' | sudo -S bash '%f'",
  :shutdown_cmd => "halt -h -p",

  :postinstall_files => [
    "#{scripts}/base.sh",
    "#{scripts}/vagrant.sh",
    "#{scripts}/common.sh",
    "#{scripts}/keyboard-be.sh",
    "#{scripts}/puppet.sh",
    "#{scripts}/virtualbox.sh",
    "#{scripts}/cleanup.sh",
    "#{scripts}/zerodisk.sh",
    #"#{scripts}/shutdown.sh",
  ],
}
