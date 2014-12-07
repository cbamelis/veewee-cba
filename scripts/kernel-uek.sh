#!/bin/bash
source common.sh

########## add oracle repo ##########

debian return 0
ensure_packages wget
el5 wget http://public-yum.oracle.com/public-yum-el5.repo -P /etc/yum.repos.d/
el6 wget http://public-yum.oracle.com/public-yum-ol6.repo -P /etc/yum.repos.d/


########## install kernel-uek ##########

ensure_packages kernel-uek kernel-uek-devel


########## make sure we use the UEK kernel after reboot ##########

GRUB_CFG=/boot/grub/menu.lst
sed -i 's/^default=.*/default=0/' ${GRUB_CFG}
sed -i 's/^timeout=.*/timeout=2/' ${GRUB_CFG}
sed -i 's/^hiddenmenu//' ${GRUB_CFG}
find /boot -iname "vmlinuz*" | grep -v uek | xargs grubby --config-file ${GRUB_CFG} --remove-kernel
cp ${GRUB_CFG} /etc/grub.conf


########## reboot ##########

shutdown now -r
sleep 100

