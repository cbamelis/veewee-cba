#!/bin/bash
source common.sh

# zero out the free space to save space in the final image
echo "Blanking free space..."
dd if=/dev/zero of=/EMPTY bs=10M
rm -f /EMPTY

# clean swap
SWAPPART=`cat /proc/swaps | tail -n1 | awk '{print $1}'`
swapoff ${SWAPPART}
dd if=/dev/zero of=${SWAPPART} bs=10M
mkswap ${SWAPPART}
swapon ${SWAPPART}

