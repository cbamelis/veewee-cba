#!/bin/bash
source common.sh

########## add puppet repo ##########

debian  http_package_install  http://apt.puppetlabs.com                                          puppetlabs-release-${OS_CODE_NAME}.deb
el      http_package_install  http://yum.puppetlabs.com/el/${OS_MAJOR_VERSION}/products/${ARCH}  puppetlabs-release-${OS_MAJOR_VERSION}-11.noarch.rpm

########## install puppet ##########

ensure_packages puppet facter rubygems ruby-augeas

