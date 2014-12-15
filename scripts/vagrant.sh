#!/bin/bash
source common.sh

########## vagrant user stuff ##########

VAGRANT_USER=vagrant
VAGRANT_GROUP=${VAGRANT_USER}
VAGRANT_PASSWORD=${VAGRANT_USER}

# add vagrant sudo user
groupadd ${VAGRANT_GROUP}
user_add ${VAGRANT_USER} ${VAGRANT_PASSWORD} ${VAGRANT_GROUP}
sudoers_without_password ${VAGRANT_USER}

# install (insecure!) ssh key for user
SSH_FOLDER=/home/${VAGRANT_USER}/.ssh
KEYFILE=${SSH_FOLDER}/authorized_keys
if ! test -f ${KEYFILE}; then
	ensure_packages wget \
	&& mkdir -pm 700 ${SSH_FOLDER} \
	&& wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O ${KEYFILE} \
	&& chmod 0600 ${KEYFILE} \
	&& chown -R ${VAGRANT_USER} ${SSH_FOLDER}/..
fi

# validate by showing user id
echo -en 'Vagrant user details : ' && id ${VAGRANT_USER}

