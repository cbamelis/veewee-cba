#!/bin/bash
source common.sh

if (test -z ${TOMTOM}); then
  ifapt apt-get clean
  ifapt apt-get -y upgrade
  ifyum yum -y clean all
  ifyum yum -y upgrade
fi
exit 0

