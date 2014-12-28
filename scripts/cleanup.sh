#!/bin/bash
source common.sh

# remove traces of mac address from network configuration
rm -f /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
el find /etc/sysconfig/network-scripts -name "ifcfg-eth*" -exec sed -i /HWADDR/d {} \;
el find /etc/sysconfig/network-scripts -name "ifcfg-eth*" -exec sed -i /UUID/d {} \;

# remove GCC and other build related packages
#remove_packages make gcc dkms  # don't remove these packages: redhat-lsb-core is dependent on these
#debian remove_packages linux-headers-${KERNEL_VERSION} xserver-xorg         build-essential
el   remove_packages kernel-devel-${KERNEL_VERSION}  xorg-x11-server-Xorg glibc-devel glibc-headers kernel-headers mesa-libGL

# if an Oracle UEK kernel is installed: remove all other kernels
uek rpm -qa | uek grep ^kernel | uek grep -v ^kernel-uek | uek xargs yum remove -y

# remove packages we don't need any more
el ensure_packages yum-utils
el package-cleanup -y --oldkernels --count=1
#el package-cleanup --leaves --exclude-bin | grep -v yum | xargs yum remove -y

# clean package cache
el yum -y clean all
debian apt-get -y autoremove
debian apt-get -y clean

# remove root password if vagrant user exists
#test -d /home/vagrant/ && passwd -d root

# remove not required files
find /var/log -iname "*.log" | xargs rm -f
find /tmp ! -fstype vboxsf -type f -print0 | xargs -0 rm
find /tmp ! -fstype vboxsf -type d -empty -delete
test -d /tmp || mkdir /tmp
chmod 0777 /tmp

# remove dummy logical volume
debian lvremove -f /dev/vg/lv_autofill

# list installed packages
list_installed_packages

function zeroDisk() {
  # zero out the free space to save space in the final image
  for ROOT in $(cat /proc/mounts | grep ext4 | cut -d" " -f 2); do
    echo "Blanking free space on ${ROOT}..."
    dd if=/dev/zero of=${ROOT}/EMPTY bs=10M
    rm -f ${ROOT}/EMPTY
  done

  # find swap partition and remember UUID
  SWAPPART=$(cat /proc/swaps | tail -n1 | awk '{print $1}')
  OLD_UUID=`blkid ${SWAPPART} -s UUID -o value`

  # zero out swap space and re-initialize
  echo "Blanking swap space..."
  swapoff ${SWAPPART}
  dd if=/dev/zero of=${SWAPPART} bs=10M
  mkswap ${SWAPPART}
  swapon ${SWAPPART}

  # update swap space UUID in /etc/fstab
  NEW_UUID=$(blkid ${SWAPPART} -s UUID -o value)
  #OLD_UUID=$(echo "${OLD_UUID}" | sed 's/\-/\\\-/g')
  #NEW_UUID=$(echo "${NEW_UUID}" | sed 's/\-/\\\-/g')
  UUID_UPDATE="s/${OLD_UUID}/${NEW_UUID}/"
  sed -i "${UUID_UPDATE}" /etc/fstab
}

ifkvm exit 0
zeroDisk
