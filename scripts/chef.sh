#!/bin/bash
source common.sh

########## install chef ##########

ensure_packages wget bash
wget https://www.opscode.com/chef/install.sh -q -O - | bash

# validate by showing installed package versions
echo -en 'Chef version : ' && chef --version
