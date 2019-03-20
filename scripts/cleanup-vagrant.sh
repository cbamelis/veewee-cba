#!/bin/bash
source common.sh


########## vagrant user stuff ##########

VAGRANT_USER=vagrant
VAGRANT_GROUP=${VAGRANT_USER:?}

# remove grant user and group
user_remove ${VAGRANT_USER:?}
group_remove ${VAGRANT_GROUP:?}

