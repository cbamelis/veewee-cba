#!/bin/bash

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin

########## check OS architecture and version ##########

KERNEL_VERSION=$(uname -r)
ARCH=$(uname -m)
test "${ARCH}" != "x86_64" && ARCH='i386'

unset EL
unset DEBIAN
unset UBUNTU
unset TOMTOM

if test -e /etc/debian_version; then
	OS_DESCRIPTION=$(lsb_release -sd)
	OS_FULL_VERSION=$(lsb_release -sr)
	OS_CODE_NAME=$(lsb_release -sc)
	OS_DISTRIBUTOR_ID=$(lsb_release -si)
	if [ $OS_DISTRIBUTOR_ID = 'Ubuntu' ]; then
	  UBUNTU=1
    else
      DEBIAN=1
	fi
fi

test -e /etc/centos-release && RELEASE_FILE=/etc/centos-release || RELEASE_FILE=/etc/redhat-release
if test -e ${RELEASE_FILE}; then
	EL=1
	OS_FULL_VERSION=$(grep -o -E '([[:digit:]]+.[[:digit:]]+)' ${RELEASE_FILE})
fi

OS_MAJOR_VERSION=$(echo ${OS_FULL_VERSION} | cut -d. -f1)

test -d /etc/yum.repos.d && grep ttg.global /etc/yum.repos.d/*.repo > /dev/null && TOMTOM=1
test -d /etc/yum.managedrepos.d && grep flatns.net /etc/yum.managedrepos.d/*.repo > /dev/null && TOMTOM=1


########## hypervisor functions ##########

function ifvbox() {
    ensure_packages dmidecode
    if (dmidecode | grep -i 'vboxver' > /dev/null); then
		"$@"; return $?
    else
        return 1
    fi
}

function ifkvm() {
    ensure_packages dmidecode
    if (dmidecode | grep 'Manufacturer: Bochs' > /dev/null); then
		"$@"; return $?
    else
        return 1
    fi
}

function ifvmware() {
    if (lspci | grep 'VMware' > /dev/null); then
		"$@"; return $?
    else
        return 1
    fi
}


########## package manager dependent ##########

function ifapt() {
  debian "$@" && return $?
  ubuntu "$@" && return $?
  return 1
}

function ifyum() {
  el "$@" && return $?
  return 1
}


########## operating system dependent ##########

function el() {
	if (test ! -z ${EL}); then
		"$@"; return $?
	else
		return 1
	fi
}

function el5() {
	if (el test ${OS_MAJOR_VERSION} -eq 5); then
		"$@"; return $?
	else
		return 1
	fi
}

function el6() {
	if (el test ${OS_MAJOR_VERSION} -eq 6); then
		"$@"; return $?
	else
		return 1
	fi
}

function el7() {
	if (el test ${OS_MAJOR_VERSION} -eq 7); then
		"$@"; return $?
	else
		return 1
	fi
}

function uek() {
    if (el is_package_installed kernel-uek); then
		"$@"; return $?
    else
        return 1
    fi
}

function debian() {
	if (test ! -z ${DEBIAN}); then
		"$@"; return $?
	else
		return 1
	fi
}

function ubuntu() {
	if (test ! -z ${UBUNTU}); then
		"$@"; return $?
	else
		return 1
	fi
}


########## functions hiding OS differences ##########

function is_package_installed() {
	local PKG_NAME=$1
	test -z ${PKG_NAME} && return 1
	ifapt dpkg-query -W -f='${Status}\n' ${PKG_NAME} | grep -v "not-installed" > /dev/null 2>&1 \
	|| ifyum rpm -q ${PKG_NAME} > /dev/null 2>&1
	return $?
}

function _install_package() {
	local PKG_NAME=$1
	test -z ${PKG_NAME} && return 1
	ifapt    dpkg -i  ${PKG_NAME} \
	|| ifyum rpm -ivh ${PKG_NAME}
	return $?
}

function _install_packages() {
	ifapt apt-get -y install "$@" \
	|| ifyum yum  -y install "$@"
	return $?
}

function _remove_packages() {
	ifapt    apt-get -y purge  "$@" \
	|| ifyum yum     -y remove "$@"
	return $?
}

function ensure_packages() {
	local PKG_NAME=$1
	unset PACKAGES_TO_INSTALL
	while test ! -z ${PKG_NAME}; do
		is_package_installed ${PKG_NAME} || PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} ${PKG_NAME}"
		shift 1
		local PKG_NAME=$1
	done
	test -z "${PACKAGES_TO_INSTALL}" && return 0
	_install_packages ${PACKAGES_TO_INSTALL}
}

function remove_packages() {
	local PKG_NAME=$1
	unset PACKAGES_TO_REMOVE
	while test ! -z ${PKG_NAME}; do
		is_package_installed ${PKG_NAME} && PACKAGES_TO_REMOVE="${PACKAGES_TO_REMOVE} ${PKG_NAME}"
		shift 1
		local PKG_NAME=$1
	done
	test -z "${PACKAGES_TO_REMOVE}" && return 0
	_remove_packages ${PACKAGES_TO_REMOVE}
}

function http_package_install() {
	local PKG_HTTP=$1
	local PKG_NAME=$2
	ensure_packages wget
	wget ${PKG_HTTP}/${PKG_NAME} && _install_package ${PKG_NAME} && rm ${PKG_NAME} && return $?
	return 1
}

function list_installed_packages() {
    ifapt    dpkg-query -W \
    || ifyum rpm -qa | sort
}

function user_add() {
	local USER_NAME=$1
	local USER_PASSWORD=$2
	local USER_GROUP=$3

	el useradd ${USER_NAME} -g ${USER_GROUP} -m -s /bin/bash \
		&& echo "${USER_PASSWORD}" | passwd --stdin ${USER_NAME} \
		&& return $?

	ifapt ensure_packages perl \
		&& useradd ${USER_NAME} -g ${USER_GROUP} -p $(perl -e "print crypt(\"${USER_NAME}\", \"${USER_PASSWORD}\")") -m -s /bin/bash \
		&& return $?

	return 1
}

function bash_dot_d() {
	local USER_NAME=$1
	test -z ${USER_NAME} && return 1
	BASH_D=/home/${USER_NAME}/.bash.d
	BASHRC=/home/${USER_NAME}/.bashrc
	test -d ${BASH_D} || mkdir -p ${BASH_D}
    echo -e '\nfor F in $HOME/.bash.d/*.sh; do source ${F}; done\n unset F' >> ${BASHRC}
    echo 'HISTFILESIZE=2500' > ${BASH_D}/bash_history.sh
    chown -R ${USER_NAME}:${USER_NAME} ${BASH_D} ${BASHRC}
    chmod a+x ${BASH_D}/*
}

function sudoers_remove() {
	local USER_NAME=$1
	test -z ${USER_NAME} && return 1
    test -f /etc/sudoers.d/${USER_NAME} && rm -f /etc/sudoers.d/${USER_NAME}
    sed -i "s/^${USER_NAME} .*//" /etc/sudoers
}

function sudoers_without_password() {
	local USER_NAME=$1
	test -z ${USER_NAME} && return 1
	local USER_SUDOERS="${USER_NAME}        ALL=(ALL)       NOPASSWD: ALL"
	if test -d /etc/sudoers.d; then
		echo ${USER_SUDOERS} >> /etc/sudoers.d/${USER_NAME} \
		&& chmod 0440 /etc/sudoers.d/${VAGRANT_USER}
	else
		echo ${USER_SUDOERS} >> /etc/sudoers
	fi
	return $?
}

