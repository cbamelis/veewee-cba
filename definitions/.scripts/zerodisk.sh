#!/bin/bash
source common.sh

# zero out the free space to save space in the final image
echo "Blanking free space..."
dd if=/dev/zero of=/EMPTY bs=10M
rm -f /EMPTY

# find swap partition and remember UUID
SWAPPART=`cat /proc/swaps | tail -n1 | awk '{print $1}'`
OLD_UUID=`blkid ${SWAPPART} -s UUID -o value`

# zero out swap space and re-initialize
echo "Blanking swap space..."
swapoff ${SWAPPART}
dd if=/dev/zero of=${SWAPPART} bs=10M
mkswap ${SWAPPART}
swapon ${SWAPPART}

# update swap space UUID in /etc/fstab
NEW_UUID=`blkid ${SWAPPART} -s UUID -o value`
#OLD_UUID=`echo "${OLD_UUID}" | sed 's/\-/\\\-/g'`
#NEW_UUID=`echo "${NEW_UUID}" | sed 's/\-/\\\-/g'`
UUID_UPDATE="s/${OLD_UUID}/${NEW_UUID}/"
sed -i "${UUID_UPDATE}" /etc/fstab

