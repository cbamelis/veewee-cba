#!/bin/bash
source common.sh

########## add useful repositories ##########

if [ test -z "${TOMTOM}" ]; then
  EPEL_URL=http://fedora.cu.be/epel/${OS_MAJOR_VERSION}/${ARCH}
  el5 http_package_install ${EPEL_URL} epel-release-5-4.noarch.rpm
  el6 http_package_install ${EPEL_URL} epel-release-6-8.noarch.rpm
  el7 http_package_install ${EPEL_URL} epel-release-7-2.noarch.rpm

  el http_package_install http://packages.sw.be/rpmforge-release rpmforge-release-0.5.3-1.el${OS_MAJOR_VERSION}.rf.${ARCH}.rpm
fi

########## install base tools ##########

debian ensure_packages  htop wget curl rsync sux man-db vim
el     ensure_packages  htop wget curl rsync man vim-enhanced

# validate by showing installed package versions
   echo -en 'htop  version : ' && htop  --version \
&& echo -en 'wget  version : ' && wget  --version \
&& echo -en 'curl  version : ' && curl  --version \
&& echo -en 'rsync version : ' && rsync --version \
&& echo -en 'man   version : ' && man   --version \
&& echo -en 'vim   version : ' && vim   --version

