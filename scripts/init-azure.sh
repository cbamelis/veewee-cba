#!/bin/bash
source common.sh

set -x

##### CentOS6 #####

function el6_azure() {
  # Inspired by:
  # - https://docs.microsoft.com/bs-latn-ba/azure/virtual-machines/linux/create-upload-centos#centos-6x
  # - https://www.jpaul.me/azure/centos-6-azure-tips/

  # In CentOS 6, NetworkManager can interfere with the Azure Linux agent. Uninstall this package
  remove_packages NetworkManager
  
  # yum: only cache packages
  echo "http_caching=packages" >> /etc/yum.conf

  # configure network  
  cat > /etc/sysconfig/network << EOF
NETWORKING=yes
HOSTNAME=azurevm
EOF
  
  cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
TYPE=Ethernet
USERCTL=no
PEERDNS=yes
IPV6INIT=no
EOF

  # Modify udev rules to avoid generating static rules for the Ethernet interface
  ln -s /dev/null /etc/udev/rules.d/75-persistent-net-generator.rules
  rm -f /etc/udev/rules.d/70-persistent-net.rules
  
  # Ensure the network service will start at boot time
  chkconfig network on

  # add cloud-init support
  ensure_packages cloud-init cloud-utils cloud-utils-growpart
  cloud-init init --local
  rm -rf /var/lib/cloud
  
  # install python2.7 using scl (CentOS 6 python 2.6 is not good enough for azure-cli/awscli)
  ensure_packages centos-release-scl
  ensure_packages python27
  
  # install azure cli
  scl enable python27 "pip install azure-cli"
  cat > /usr/bin/az << "EOF"
#!/bin/bash
export LD_LIBRARY_PATH=/opt/rh/python27/root/usr/lib64
export PYTHONPATH=/usr/lib64/az/lib/python2.7:/usr/lib64/az/lib/python2.7/site-packages
/opt/rh/python27/root/usr/bin/python2.7 -sm azure.cli "$@"
EOF
  chmod a+x /usr/bin/az
  
  # install aws cli
  scl enable python27 "pip install awscli"
  cat > /usr/bin/aws << "EOF"
#!/bin/bash
export LD_LIBRARY_PATH=/opt/rh/python27/root/usr/lib64
/opt/rh/python27/root/usr/bin/aws "$@"
EOF
  chmod a+x /usr/bin/aws

  # package installation
  ensure_packages python-pyasn1 WALinuxAgent
  chkconfig waagent on

  # reconfigure grub
  for REPLACE in "s|rhgb||g" "s|quiet||g" "s|crashkernel=auto|rootdelay=300\ console=ttyS0\ earlyprintk=ttyS0|g" ; do
    sed -i -e "${REPLACE}" /boot/grub/grub.conf
  done
  
  # configure agetty serial console
  cat > /etc/init/ttyS0.conf << "EOF"
#This service maintains a agetty on ttyS0.
stop on runlevel [S016]
start on [23]
respawn 
exec agetty -h -L -w /dev/ttyS0 115200 vt102
EOF

  # rebuild initrd
  cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.before_update.bak
  dracut -v -f
}

##### CentOS7 #####

function el7_azure() {
  # Inspired by:
  # - https://docs.microsoft.com/bs-latn-ba/azure/virtual-machines/linux/create-upload-centos#centos-70

  # configure network  
  cat > /etc/sysconfig/network << EOF
NETWORKING=yes
HOSTNAME=localhost.localdomain  
EOF
  
  cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
TYPE=Ethernet
USERCTL=no
PEERDNS=yes
IPV6INIT=no
NM_CONTROLLED=no
EOF

  # Modify udev rules to avoid generating static rules for the Ethernet interface
  ln -s /dev/null /etc/udev/rules.d/75-persistent-net-generator.rules

  # add cloud-init support
  ensure_packages cloud-init cloud-utils cloud-utils-growpart
  cloud-init init --local
  rm -rf /var/lib/cloud

  # install aws cli
  ensure_packages python36 python36-pip
  pip3.6 install --upgrade awscli

  # package installation
  ensure_packages python-pyasn1 WALinuxAgent
  systemctl enable waagent

  # reconfigure grub
  for REPLACE in "s|rhgb||g" "s|quiet||g" "s|crashkernel=auto|rootdelay=300\ console=ttyS0\ earlyprintk=ttyS0\ net.ifnames=0|g" ; do
    sed -i -e "${REPLACE}" /etc/default/grub
  done
  grub2-mkconfig -o /boot/grub2/grub.cfg

  # CBA note: I'm still not sure, but the only kernels where Lsv2 NVMe storage is visible,
  # seem to have a pci-hyperv kernel module
  modinfo pci-hyperv || ( echo "NVMe storage of Azure Lsv2 SKU will not work by lack of pci-hyperv kernel module" && exit -1 )

  # rebuild initrd
  echo "add_drivers+=\" hv_vmbus hv_netvsc hv_storvsc pci_hyperv \"" >> /etc/dracut.conf
  dracut -f -v
}

##### Ubuntu #####

function ubuntu_azure() {
  # Inspired by:
  # - https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-ubuntu
  
  # upgrade repos
  ubuntu1604 sed -i 's/[a-z][a-z].archive.ubuntu.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list \
  || ubuntu1804 sed -i 's/[a-z][a-z].archive.ubuntu.com/azure.archive.ubuntu.com/g' /etc/apt/sources.list
  apt-get update -q

  # add cloud-init support
  ensure_packages cloud-init cloud-utils
  cloud-init init --local
  rm -rf /var/lib/cloud
  
  # install aws cli
  ensure_packages python-setuptools python-pip
  pip install awscli
  
  # perform full upgrade
  apt-get upgrade -fy
  
  # package installation
  ensure_packages walinuxagent
  
  # reconfigure grub
  sed -i -e 's|GRUB_CMDLINE_LINUX_DEFAULT.*|GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0,115200n8 earlyprintk=ttyS0,115200 rootdelay=300"|g' /etc/default/grub
  update-grub
}


##### Run OS dependent Azure customizations #####

el6 el6_azure || el7 el7_azure || ubuntu ubuntu_azure


##### Show AZ CLI versions #####

az --version
which azcopy || exit -1
azcopy --version || :
