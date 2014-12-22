#!/bin/bash
source common.sh

########## add puppet repo (except for TT) ##########

if [ test -z "${TOMTOM-}" ]; then
  debian  http_package_install  http://apt.puppetlabs.com                                          puppetlabs-release-${OS_CODE_NAME}.deb
  el      http_package_install  http://yum.puppetlabs.com/el/${OS_MAJOR_VERSION}/products/${ARCH}  puppetlabs-release-${OS_MAJOR_VERSION}-11.noarch.rpm
fi

########## install puppet ##########

ensure_packages puppet facter

# validate by showing installed package versions
   echo -en 'Puppet version : ' && puppet --version \
&& echo -en 'Facter version : ' && facter --version

