#!/bin/bash
source common.sh

##### Deprovision using azure linux agent #####

waagent -force -deprovision
export HISTSIZE=0
sync

