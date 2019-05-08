#!/bin/bash
source common.sh

########## add useful repositories ##########

#el http_package_install http://repository.it4i.cz/mirrors/repoforge/redhat/el6/en/x86_64/rpmforge/RPMS rpmforge-release-0.5.3-1.el${OS_MAJOR_VERSION}.rf.${ARCH}.rpm || :
EPEL_URL=https://dl.fedoraproject.org/pub/epel
el6 http_package_install ${EPEL_URL} epel-release-latest-6.noarch.rpm || \
el7 http_package_install ${EPEL_URL} epel-release-latest-7.noarch.rpm || \
ifapt add-apt-repository universe || :
ifapt apt-get -y update || :


########## install base tools ##########

ifapt ensure_packages  htop wget curl inotify-tools rsync ca-certificates man-db vim x11-apps || \
el    ensure_packages  htop wget curl inotify-tools rsync ca-certificates man vim-enhanced

# validate by showing installed package versions
   echo -en 'htop    version : ' && htop  --version \
&& echo -en 'wget    version : ' && wget  --version \
&& echo -en 'inotify version : ' && inotifywait --help | head -1 \
&& echo -en 'curl    version : ' && curl  --version \
&& echo -en 'rsync   version : ' && rsync --version \
&& echo -en 'man     version : ' && man   --version \
&& echo -en 'vim     version : ' && vim   --version
