#!/bin/bash
source common.sh

# remove traces of mac address from network configuration
rm -f /etc/udev/rules.d/70-persistent-net.rules
rhel find /etc/sysconfig/network-scripts -name "ifcfg-eth*" -exec sed -i /HWADDR/d {} \;
rhel find /etc/sysconfig/network-scripts -name "ifcfg-eth*" -exec sed -i /UUID/d {} \;

# remove GCC and other build related packages
remove_packages make gcc dkms
debian remove_packages linux-headers-${KERNEL_VERSION} xserver-xorg         build-essential
rhel   remove_packages kernel-devel-${KERNEL_VERSION}  xorg-x11-server-Xorg glibc-devel glibc-headers kernel-headers mesa-libGL

# if an Oracle UEK kernel is installed: remove all other kernels
uek rpm -qa | grep ^kernel | grep -v ^kernel-uek | xargs yum remove -y

# remove packages we don't need any more
rhel ensure_packages yum-utils
rhel package-cleanup -y --oldkernels --count=1
#rhel package-cleanup --leaves --exclude-bin | grep -v yum | xargs yum remove -y

# clean package cache
rhel yum -y clean all
debian apt-get -y autoremove
debian apt-get -y clean

# delete veewee user
VEEWEE_USER=veewee
rm -rf /home/${VEEWEE_USER}/*.iso
#test -d /home/${VEEWEE_USER} && userdel -f ${VEEWEE_USER} && rm -rf /home/${VEEWEE_USER} && rm -rf /etc/sudoers.d/${VEEWEE_USER}
#sed -i 's/^veewee.*$//' /etc/sudoers

# remove not required files
rm -rf /tmp/*
find /var/log -iname "*.log" | xargs rm -f
find / -iname ".bash_history" | xargs rm -f

