#!/bin/bash
source common.sh

########## install chef ##########

ensure_packages wget
rhel wget https://www.opscode.com/chef/install.sh -q -O - | bash
ubuntu wget https://www.opscode.com/chef/install.sh -q -O - | bash

