#!/bin/bash
source common.sh

########## VirtualBox guest additions ##########

# install dependencies
ensure_packages dmidecode

# detect virtualbox version
unset VBOX_VERSION
VBOX_VERSION=`cat /home/veewee/.vbox_version`
test -z ${VBOX_VERSION} && dmidecode | grep -i virtualbox 2>&1 >/dev/null \
	&& VBOX_VERSION=`dmidecode | grep -i vboxver | cut -d_ -f2` \

# install guest additions when VirtualBox is detected
if test ! -z ${VBOX_VERSION}; then
    echo "Detected VirtualBox ${VBOX_VERSION}"

	# install dependencies
	ensure_packages dkms perl make gcc bzip2
	el     ensure_packages  kernel-devel-${KERNEL_VERSION}  xorg-x11-server-Xorg
	debian ensure_packages  linux-headers-${KERNEL_VERSION} xserver-xorg          libdbus-1-3 build-essential

	# init
	TMP_DIR=/tmp/mnt
	MNT_DIR=${TMP_DIR}/cdrom
	EXE=${MNT_DIR}/VBoxLinuxAdditions.run
	ISO=VBoxGuestAdditions_${VBOX_VERSION}.iso
	mkdir -p ${MNT_DIR}

	# mount + install guest additions
    mount -o loop ${ISO} ${MNT_DIR} && sh ${EXE}

	# clean up
	umount -f ${MNT_DIR}
	rm -rf ${TMP_DIR}
else
    echo "Could not detect VirtualBox version!"
fi

