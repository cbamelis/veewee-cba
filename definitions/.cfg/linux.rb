scripts = "../.scripts"

LINUX = {
  :cpu_count   => "1",        # 1 CPU
  :memory_size => "512",      # 0.5 GB memory
  :disk_size   => "1048576",  # 1 TB HDD size
  :disk_format => "VDI",
  :hostiocache => "on",

  :iso_download_timeout => "1000",  # time required to download missing ISO
  :boot_wait            => "5",     # wait to display boot/install menu
  :kickstart_timeout    => "120",   # wait for typing boot command + starting setup + network configuration + kickstart download
  :ssh_login_timeout    => "1200",  # wait long enough for OS install + first reboot + ssh service
  :postinstall_timeout  => "1200",  # give postinstall scripts enough time to finish

  :ssh_password => "vagrant",
  :ssh_user     => "vagrant",
  :ssh_key      => "",

  :kickstart_port => "7122",
  :ssh_host_port  => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd       => "echo '%p' | sudo -S bash '%f'",
  :shutdown_cmd   => "halt -h -p",

  :postinstall_files => [
    "#{scripts}/common.sh",
    "#{scripts}/vagrant.sh",
    "#{scripts}/puppet.sh",
    #"#{scripts}/chef.sh",
    "#{scripts}/base.sh",
    #"#{scripts}/keyboard-be.sh",
    "#{scripts}/vmware.sh",
    "#{scripts}/virtualbox.sh",
    "#{scripts}/cleanup.sh",
    #"#{scripts}/shutdown.sh",
  ],
}
