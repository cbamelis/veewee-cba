#!/bin/bash
source common.sh

########## install chef ##########

ensure_packages wget bash
wget https://www.opscode.com/chef/install.sh -q -O - | bash

