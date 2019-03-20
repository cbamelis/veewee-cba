#!/bin/bash
source common.sh

ifapt apt-get clean || ifyum yum -y clean all
ifapt apt-get -fy upgrade || ifyum yum -y upgrade

