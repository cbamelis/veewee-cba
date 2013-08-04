#!/bin/bash
source common.sh

########## add puppet repo ##########

rhel5   http_package_install  http://yum.puppetlabs.com/el/${OS_MAJOR_VERSION}/products/${ARCH}  puppetlabs-release-5-7.noarch.rpm
rhel6   http_package_install  http://yum.puppetlabs.com/el/${OS_MAJOR_VERSION}/products/${ARCH}  puppetlabs-release-6-7.noarch.rpm
debian  http_package_install  http://apt.puppetlabs.com                                          puppetlabs-release-${OS_CODE_NAME}.deb

########## install puppet ##########

ensure_packages puppet facter rubygems

