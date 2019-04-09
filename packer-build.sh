#!/bin/bash

# exit on error
set -e

# if user wants detailed packer output (by setting PACKER_LOG), then also
# increase verbosity of this script
test ! -z "${PACKER_LOG}" && test ${PACKER_LOG} -ne 0 && env | sort && set -x || set +x

# defaults
PATH_JSON=./templates
PATH_OS=${PATH_JSON:?}/os
PATH_MACHINES=${PATH_JSON:?}/machines
PATH_KICKSTART=./kickstart

function help_templates() {
  local MSG=$1
  echo -e "${MSG:?} (see ${PATH_JSON:?}):"
  for FILE in ${PATH_JSON:?}/*.json; do
    FILE_CONTENT=$(cat ${FILE:?} | grep -i description | cut -d ":" -f 2 | sed 's/"//g')
    FILE=${FILE%.json}
    FILE=${FILE#${PATH_JSON}/}
    printf "    %-30s" ${FILE:?}
    echo ${FILE_CONTENT%\,}
  done
  return 1
}

function help_machines() {
  local MSG=$1
  echo -e "${MSG:?} (see ${PATH_MACHINES:?}):"
  for FILE in $(find ${PATH_MACHINES:?} -type f -iname "*.json" | sort); do
    FILE_CONTENT=$(cat ${FILE:?} | sed ':a;N;$!ba;s/\n/ /g' )
    FILE=${FILE%.json}
    FILE=${FILE#${PATH_MACHINES}/}
    printf "    %-30s" ${FILE:?}
    echo ${FILE_CONTENT:?}
  done
  return 1
}

function help_kickstart() {
  local MSG=$1
  echo -e "${MSG:?} (see ${PATH_KICKSTART:?}):"
  for FILE in $(find ${PATH_KICKSTART:?} -type f -iname "*.cfg" | sort); do
    FILE_CONTENT=$(cat ${FILE:?} | head -1 )
    FILE=${FILE%.cfg}
    FILE=${FILE#${PATH_KICKSTART}/}
    printf "    %-30s" ${FILE:?}
    echo ${FILE_CONTENT:?}
  done
  return 1
}

function help_os() {
  local MSG=$1
  echo -e "${MSG:?} (see ${PATH_OS:?}):"
  for FILE in $(find ${PATH_OS:?} -type f -iname "*.json" | sort); do
    FILE_CONTENT=$(cat ${FILE:?} | jq ".ISO_FILENAME" | tr -d '"' )
    FILE=${FILE%.json}
    FILE=${FILE#${PATH_OS}/}
    printf "    %-30s" ${FILE:?}
    echo "# ${FILE_CONTENT%\,}"
  done
  return 1
}

function help_hyperv() {
  local MSG=$1
  echo -e "${MSG:?}"
  echo    "    virtualbox"
  echo    "    vmware"
  echo    "    qemu"
  echo    "    azure"
  return 1
}

function help() {
  local MSG=$1
  echo -e "${MSG:?}"
  echo "Usage:"
  echo "  $0 <packer_template> <kickstart> <machine_type> <operating_system> <hypervisor>"
  echo ""
  help_templates "\n  <packer_template> is a JSON packer template; currently supported" ||
  help_kickstart "\n  <kickstart> is a kickstart/preseed file containing all answers for unattended OS installation; currently supported" ||
  help_machines  "\n  <machine_type> is a JSON file with hardware description; currently supported" ||
  help_os        "\n  <operating_system> is a JSON file with Operating System description; currently supported" ||
  help_hyperv    "\n  <hypervisor> is the name of the hypervisor (packer builder) to use; currently supported:" ||
  echo ""
  exit -1
}

# check command line parameters; print help if incorrect
[ $# -ne 5 ] && help "\nExpected 5 command line parameters!\n"

# verify parameter packer_template
TEMPLATE=$1
test -f ${TEMPLATE:?} || TEMPLATE=${PATH_JSON:?}/${TEMPLATE:?}.json
test -f ${TEMPLATE:?} || help_templates "\nUnable to find the given packer_template (\"${TEMPLATE:?}\")" || exit -1
shift

# verify parameter kickstart
KICKSTART=$1
test -f ${PATH_KICKSTART:?}/${KICKSTART:?} || KICKSTART=${KICKSTART:?}.cfg
test -f ${PATH_KICKSTART:?}/${KICKSTART:?} || help_kickstart "\nUnable to find the given kickstart (\"${KICKSTART:?}\")" || exit -1
shift

# verify parameter machine_type
MACHINE_TYPE=$1
test -f ${MACHINE_TYPE:?} || MACHINE_TYPE=${PATH_MACHINES:?}/${MACHINE_TYPE:?}.json
test -f ${MACHINE_TYPE:?} || help_machines "\nUnable to find the given machine_type (\"${MACHINE_TYPE:?}\")" || exit -1
shift

# verify parameter operating_system
OS=$1
OS_FULL=${PATH_OS:?}/${OS:?}.json
test -f ${OS_FULL:?} || help_os "Unable to find the given operating_system (\"${OS:?}\")" || exit -1
shift

# veryfiy parameter hypervisor
BUILDER=$1
if (test ${BUILDER:?} == "virtualbox"); then
  PACKER_BUILDER="virtualbox-iso"
  HYPERVISOR_INIT="init-virtualbox.sh"
elif (test ${BUILDER:?} == "vmware"); then
  PACKER_BUILDER="vmware-iso"
  HYPERVISOR_INIT="init-vmware.sh"
elif (test ${BUILDER:?} == "qemu"); then
  PACKER_BUILDER="qemu"
  HYPERVISOR_INIT="true"
elif (test ${BUILDER:?} == "azure"); then
  PACKER_BUILDER="qemu"
  HYPERVISOR_INIT="init-azure.sh"
  HYPERVISOR_CLEANUP="cleanup-vagrant.sh && cleanup-azure.sh"
  EXCEPT_VAGRANT="-except=vagrant"
else
  help_hyperv "Unsupported hypervisor (\"${BUILDER:?}\")" || exit -1
fi
shift

# check if we need to run headless
EXTRA="-var HEADLESS=true"
test ! -z "$(which xset)" && xset q > /dev/null && EXTRA="-on-error=ask" || :

# use packer to build box with default output file name; specify BOX_NAME before running this script if you want to override
OS_NAME=$(cat ${OS_FULL:?} | jq ".ISO_FILENAME" | tr -d '"')
OS_NAME=${OS_NAME%.iso}
KICKSTART_NAME=$(basename ${KICKSTART:?})
KICKSTART_NAME=${KICKSTART_NAME%.cfg}
export BOX_NAME=${BOX_NAME:-${BUILDER:?}-${OS_NAME}-${KICKSTART_NAME:?}}

# build the VM image using packer
packer build \
  -force \
  ${EXTRA:?} \
  -var EXTRA_SCRIPTS="${EXTRA_SCRIPTS:-true}" \
  -var HYPERVISOR_INIT="${HYPERVISOR_INIT:-true}" \
  -var HYPERVISOR_CLEANUP="${HYPERVISOR_CLEANUP:-true}" \
  -var OUTPUT_NAME="${BOX_NAME:?}" \
  -var PACKER_KICKSTART="${KICKSTART:?}" \
  -var-file=${MACHINE_TYPE:?} \
  -var-file=${OS_FULL:?} \
  -only="${PACKER_BUILDER:?}" \
  ${EXCEPT_VAGRANT} \
  "${TEMPLATE:?}"

# hypervisor specific logging
if (test ${BUILDER:?} == "azure"); then
  echo "Created Azure compatible VM image: ./packer-output/${BOX_NAME:?}/${BOX_NAME:?}.qcow2 (needs conversion to fixed size VHD)"
else
  echo "Created ${BUILDER:?} vagrant box: ./vagrant-boxes/${BOX_NAME:?}.box"
fi

