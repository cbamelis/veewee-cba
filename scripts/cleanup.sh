#!/bin/bash
source common.sh

echo "Disk space before cleanup:"
df -h

# remove VirtualBox guest additions ISO
rm -f /home/packer/VBoxGuestAdditions*.iso

# remove traces of mac address from network configuration
UDEV_NET=/etc/udev/rules.d/70-persistent-net.rules
test -f ${UDEV_NET} && rm -rf ${UDEV_NET}
#test -d ${UDEV_NET} || mkdir -p ${UDEV_NET}
el find /etc/sysconfig/network-scripts -name "ifcfg-eth*" -exec sed -i /HWADDR/d {} \; || :
el find /etc/sysconfig/network-scripts -name "ifcfg-eth*" -exec sed -i /UUID/d {} \; || :

# remove dhcp client leases
ifapt rm -f /var/lib/dhcp/dhclient.* || \
el rm -f /var/lib/dhclient/*

# remove SSH keys, but make sure new keys are generated upon first boot
rm -f /etc/ssh/ssh_host_*key*
#grep ssh-keygen /etc/rc.local || sed -i "s/exit 0//" /etc/rc.local
#grep ssh-keygen /etc/rc.local || echo -e 'ssh-keygen -A\nexit 0' >> /etc/rc.local

# remove GCC and other build related packages
#remove_packages make gcc dkms  # don't remove these packages: redhat-lsb-core is dependent on these
#ifapt remove_packages linux-headers-${KERNEL_VERSION} xserver-xorg         build-essential
#el   remove_packages kernel-devel-${KERNEL_VERSION}  xorg-x11-server-Xorg glibc-devel glibc-headers kernel-headers mesa-libGL

# remove old kernels
function el_remove_old_kernels() {
  is_package_installed kernel-uek && remove_packages kernel || :
  is_package_installed kernel-lt && remove_packages kernel || :
  is_package_installed kernel-ml && remove_packages kernel || :
  ensure_packages yum-utils
  package-cleanup -y --oldkernels --count=1
  #remove_packages yum-utils
}
function apt_remove_old_kernels() {
  dpkg --list 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs apt-get -y purge
}
el el_remove_old_kernels || ifapt apt_remove_old_kernels || :

# remove packages we don't need any more
#el package-cleanup --leaves --exclude-bin | grep -v yum | xargs yum remove -y

# clean package cache
ifapt apt-get -y autoremove --purge && \
ifapt apt-get -y clean || :
el yum -y clean all || :

# remove root password if vagrant user exists
#test -d /home/vagrant/ && passwd -d root

# clean up logs
test -f /var/log/audit/audit.log && cat /dev/null > /var/log/audit/audit.log 2>/dev/null
test -f /var/log/wtmp && cat /dev/null > /var/log/wtmp 2>/dev/null
logrotate -f /etc/logrotate.conf 2>/dev/null || :
find /var/log -iname "*.log" | xargs rm -f || :
find /var/log -iname "*.gz" | xargs rm -f || :

# clean up temp
find /tmp ! -fstype vboxsf -type f -print0 | xargs -0 rm
find /tmp ! -fstype vboxsf -mindepth 1 -type d -empty -delete
#test -d /tmp || mkdir /tmp
#chmod 0777 /tmp

# remove dummy logical volume
ifapt lvremove -f /dev/vg/lv_autofill || :

# clear bash history
history -c
unset HISTFILE

function zeroDisk() {
  # zero out the free space to save space in the final image
  for ROOT in $(cat /proc/mounts | grep ext4 | cut -d" " -f 2); do
    echo "Blanking free space on ${ROOT}..."
    dd if=/dev/zero of=${ROOT}/EMPTY bs=10M || echo "Disk full"
    rm -f ${ROOT}/EMPTY
  done

  # blank swap partitions
  for SWAPPART in $(cat /proc/swaps | tail -n +2 | awk '{print $1}'); do
    # remember UUID of swap partition
    OLD_UUID=`blkid ${SWAPPART} -s UUID -o value`

    # zero out swap space and re-initialize
    echo "Blanking swap space..."
    swapoff ${SWAPPART}
    test -f ${SWAPPART} && rm -f ${SWAPPART} && continue || :
    dd if=/dev/zero of=${SWAPPART} bs=10M || echo "Disk full"
    mkswap ${SWAPPART}

    # update swap space UUID in /etc/fstab
    NEW_UUID=$(blkid ${SWAPPART} -s UUID -o value)
    UUID_UPDATE="s/${OLD_UUID}/${NEW_UUID}/"
    sed -i "${UUID_UPDATE}" /etc/fstab
  done
}

zeroDisk || :

# list installed packages
echo "Installed packages:"
list_installed_packages
echo "Disk space after cleanup:"
df -h
el echo "Service enablement" || :
el chkconfig --list || :
