#!/bin/bash
source common.sh

########## VirtualBox guest additions ##########

# exit when not detected
ifvbox echo "Detected VirtualBox" || exit 0

# install dependencies
ensure_packages perl make gcc bzip2
el     ensure_packages  kernel*devel-${KERNEL_VERSION:?} kernel*headers-${KERNEL_VERSION:?} xorg-x11-server-Xorg || \
ifapt ensure_packages  linux-headers-${KERNEL_VERSION:?} xserver-xorg libdbus-1-3 build-essential dkms

# init
TMP_DIR=/tmp/mnt
MNT_DIR=${TMP_DIR:?}/cdrom
EXE=${MNT_DIR:?}/VBoxLinuxAdditions.run
ISO=/home/packer/VBoxGuestAdditions.iso
if [[ ! -f ${ISO} && -f /home/packer/.vbox_version ]]; then
  # detect version
  unset VBOX_VERSION
  VBOX_VERSION=$(cat /home/packer/.vbox_version)
  echo "Detected VirtualBox version ${VBOX_VERSION:?}"
  wget -O ${ISO} http://download.virtualbox.org/virtualbox/${VBOX_VERSION:?}/VBoxGuestAdditions_${VBOX_VERSION:?}.iso
fi 
mkdir -p ${MNT_DIR:?}

# mount + install
el5 export KERN_DIR=/usr/src/kernels/`uname -r`-`uname -m` || \
el6 export KERN_DIR=/usr/src/kernels/`uname -r` || \
el7 export KERN_DIR=/usr/src/kernels/`uname -r` || :
umount ${MNT_DIR:?} || umount -f ${MNT_DIR:?} || :
mount -o loop,ro ${ISO:?} ${MNT_DIR:?} && sh ${EXE:?}

# clean up
umount ${MNT_DIR:?} || umount -f ${MNT_DIR}
rm -rf ${TMP_DIR}
rm -f ${ISO}

# validate by starting service
service vboxadd start || service vboxadd-service start

