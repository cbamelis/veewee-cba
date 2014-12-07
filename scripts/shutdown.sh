#!/bin/bash
source common.sh

# remove sudoers for user (first command line parameter)
sudoers_remove $1

# shutdown
shutdown now -h

