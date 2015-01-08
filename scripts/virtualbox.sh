#!/bin/bash
source common.sh

########## VirtualBox guest additions ##########

# exit when not detected
ifvbox echo "Detected VirtualBox" || exit 0

# detect version
unset VBOX_VERSION
VBOX_VERSION=`cat ${HOME}/.vbox_version`

# exit when not detected
test -z ${VBOX_VERSION} && "Could not detect VirtualBox version" && exit -1

# install when detected
echo "Detected VirtualBox version ${VBOX_VERSION}"

# install dependencies
ensure_packages perl make gcc bzip2
el     ensure_packages  kernel-devel-${KERNEL_VERSION}  xorg-x11-server-Xorg
ifapt ensure_packages  linux-headers-${KERNEL_VERSION} xserver-xorg          libdbus-1-3 build-essential

# init
TMP_DIR=/tmp/mnt
MNT_DIR=${TMP_DIR}/cdrom
EXE=${MNT_DIR}/VBoxLinuxAdditions.run
ISO=${HOME}/VBoxGuestAdditions_${VBOX_VERSION}.iso
mkdir -p ${MNT_DIR}

# mount + install
mount -o loop,ro ${ISO} ${MNT_DIR} && sh ${EXE}

# clean up
umount -f ${MNT_DIR}
rm -rf ${TMP_DIR}
rm -f ${ISO}

# validate by starting service
service vboxadd start

