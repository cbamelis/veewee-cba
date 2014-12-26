#!/bin/bash
source common.sh

########## VirtualBox guest additions ##########

# detect virtualbox version
unset VBOX_VERSION
VBOX_VERSION=`cat .vbox_version`

# exit when virtualbox not detected
test -z ${VBOX_VERSION} && exit 0

# install guest additions when VirtualBox is detected
echo "Detected VirtualBox ${VBOX_VERSION}"

# The debian netboot installs the VirtualBox support (old) so we have to remove it
debian aptitude -y purge $(dpkg-query -W "virtualbox*" | cut -f 1)

# install dependencies
ensure_packages perl make gcc bzip2
el     ensure_packages  kernel-devel-${KERNEL_VERSION}  xorg-x11-server-Xorg
debian ensure_packages  linux-headers-${KERNEL_VERSION} xserver-xorg          libdbus-1-3 build-essential

# init
TMP_DIR=/tmp/mnt
MNT_DIR=${TMP_DIR}/cdrom
EXE=${MNT_DIR}/VBoxLinuxAdditions.run
ISO=VBoxGuestAdditions_${VBOX_VERSION}.iso
mkdir -p ${MNT_DIR}

# mount + install guest additions
mount -o loop,ro ${ISO} ${MNT_DIR} && sh ${EXE}

# clean up
umount -f ${MNT_DIR}
rm -rf ${TMP_DIR}

# validate by loading compiled kernel modules
modprobe vboxsf && service vboxadd start

