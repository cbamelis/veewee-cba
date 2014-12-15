#!/bin/bash
source common.sh

########## add useful repositories ##########

EPEL_URL=http://fedora.cu.be/epel/${OS_MAJOR_VERSION}/${ARCH}
el5 http_package_install ${EPEL_URL} epel-release-5-4.noarch.rpm
el6 http_package_install ${EPEL_URL} epel-release-6-8.noarch.rpm
el7 http_package_install ${EPEL_URL} epel-release-7-2.noarch.rpm

el http_package_install http://packages.sw.be/rpmforge-release rpmforge-release-0.5.3-1.el${OS_MAJOR_VERSION}.rf.${ARCH}.rpm

########## install base tools ##########

debian ensure_packages  htop wget curl rsync dkms sux man-db vim
el     ensure_packages  htop wget curl rsync dkms man vim-enhanced

# validate by showing installed package versions
   echo -en 'htop  version : ' && htop  --version | head -1 \
&& echo -en 'wget  version : ' && wget  --version | head -1 \
&& echo -en 'curl  version : ' && curl  --version | head -1 \
&& echo -en 'rsync version : ' && rsync --version | head -1 \
&& echo -en 'man   version : ' && man   --version | head -1 \
&& echo -en 'vim   version : ' && vim   --version | head -1

