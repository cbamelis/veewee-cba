#!/bin/bash
source common.sh

########## VMWare tools ##########

# exit when not detected
ifvmware echo "Detected VMWare" || exit 0

# init
TMP_DIR=/tmp/mnt
MNT_DIR=${TMP_DIR}/cdrom
EXE=${TMP_DIR}/vmware-tools-distrib/vmware-install.pl
ISO=${HOME}/vmware-tools.iso
mkdir -p ${MNT_DIR}

# first try to install open-vm-tools
ensure_packages open-vm-tools open-vm-tools-desktop
RETVAL=$?

# otherwise, install from uploaded iso
if (test ! ${RETVAL} -eq 0); then
  # install dependencies
  ensure_packages perl
  el ensure_packages kernel-devel-${KERNEL_VERSION} fuse-lib xorg-x11-server-Xorg
  ifapt ensure_packages linux-headers-${KERNEL_VERSION} build-essential

  # mount + install
  mount -o loop,ro ${ISO} ${MNT_DIR} && tar zxvf ${MNT_DIR}/VMwareTools-*.tar.gz -C ${TMP_DIR}/ && ${EXE} -d
  umount -f ${MNT_DIR}

  # validate by starting service
  service vmware-tools start
  RETVAL=$?
fi

# clean up
rm -rf ${TMP_DIR}
rm -f ${ISO}

# return validation status
exit ${RETVAL}
