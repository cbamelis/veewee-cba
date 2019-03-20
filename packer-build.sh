#!/bin/bash

set -e
#set -x

PATH_JSON=./templates
PATH_OS=${PATH_JSON:?}/os
PATH_MACHINES=${PATH_JSON:?}/machines
PATH_KICKSTART=./kickstart
DEFAULT_MACHINE_TYPE=small

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
  echo    "    iso2azure"
  return 1
}

function help() {
  local MSG=$1
  echo -e "${MSG:?}"
  echo "Usage:"
  echo "  $0 <packer_template> <kickstart> [<machine_type> <operating_system> <hypervisor>]"
  echo ""
  echo "  The last 3 parameters can be omitted in case of running $0 from Jenkins"
  echo "    - <machine_type> will default to \"${DEFAULT_MACHINE_TYPE:?}\""
  echo "    - <operating_system> and <hypervisor> will be parsed from the Jenkins JOB_NAME"
  echo "      which is assumed to follow naming convention <operating_system>-<hypervisor>"
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
[ $# -lt 2 ] && help "\nNot enough command line parameters!\n"
[ $# -eq 2 ] && [ -z ${JOB_NAME} ] && help "\nNot enough command line parameters (or Jenkins variable JOB_NAME not found)!\n"
[ $# -gt 5 ] && help "\nToo much command line parameters!\n"

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
[ $# -eq 0 ] && MACHINE_TYPE=${DEFAULT_MACHINE_TYPE:?}
[ $# -gt 0 ] && MACHINE_TYPE=$1 && shift
test -f ${MACHINE_TYPE:?} || MACHINE_TYPE=${PATH_MACHINES:?}/${MACHINE_TYPE:?}.json
test -f ${MACHINE_TYPE:?} || help_machines "\nUnable to find the given machine_type (\"${MACHINE_TYPE:?}\")" || exit -1

# parameters operating_system and hypervisor
if ([ $# -eq 0 ] && test ! -z ${JOB_NAME}); then
  # fetch os and hypervisor from jenkins job name
  JOB_NAME_AS_ARRAY=(${JOB_NAME//-/ })  # replace dash by space; split into array
  TOKEN_COUNT=${#JOB_NAME_AS_ARRAY[@]}
  LAST_TOKEN_INDEX=$(expr ${TOKEN_COUNT} - 1)
  BUILDER=${JOB_NAME_AS_ARRAY[${LAST_TOKEN_INDEX}]}
  CMD_EXTRA=" -force -machine-readable -var HEADLESS=true"
  OS=${JOB_NAME%-${BUILDER}}
else
  OS=$1
  BUILDER=$2
  JOB_NAME=${OS:?}-${BUILDER:?}
fi

# verify parameter os
OS_FULL=${PATH_OS:?}/${OS:?}.json
test -f ${OS_FULL:?} || help_os "Unable to find the given operating_system (\"${OS:?}\")" || exit -1

# hypervisor specific configuration
if (test ${BUILDER:?} == "virtualbox"); then
  PACKER_BUILDER="virtualbox-iso"
  HYPERVISOR_INIT="init-virtualbox.sh"
elif (test ${BUILDER:?} == "vmware"); then
  PACKER_BUILDER="vmware-iso"
  HYPERVISOR_INIT="init-vmware.sh"
elif (test ${BUILDER:?} == "qemu"); then
  PACKER_BUILDER="qemu"
  HYPERVISOR_INIT="true"
elif (test ${BUILDER:?} == "iso2azure"); then
  PACKER_BUILDER="qemu"
  HYPERVISOR_INIT="init-azure.sh"
  HYPERVISOR_CLEANUP="cleanup-vagrant.sh && cleanup-azure.sh"
else
  help_hyperv "Unsupported hypervisor (\"${BUILDER:?}\")" || exit -1
fi

# extra parameters for Jenkins runs
test ! -z ${JENKINS_URL} && export PACKER_NO_COLOR=1 && unset PACKER_LOG_PATH && unset PACKER_LOG && EXTRA="-var HEADLESS=true" || EXTRA="-on-error=ask"

# use packer to build box with default output file name is ${OS}; specify BOX_NAME before running this script if you want to override
OS_NAME=$(cat ${OS_FULL:?} | jq ".ISO_FILENAME" | tr -d '"')
OS_NAME=${OS_NAME%.iso}
KICKSTART_NAME=$(basename ${KICKSTART:?})
KICKSTART_NAME=${KICKSTART_NAME%.cfg}
export BOX_NAME=${BOX_NAME:-${OS_NAME}-${KICKSTART_NAME:?}}

# build the VM image using packer
packer build \
  -force \
  ${EXTRA} \
  -var EXTRA_SCRIPTS="${EXTRA_SCRIPTS:-true}" \
  -var HYPERVISOR_INIT="${HYPERVISOR_INIT:-true}" \
  -var HYPERVISOR_CLEANUP="${HYPERVISOR_CLEANUP:-true}" \
  -var OUTPUT_NAME="${BOX_NAME:?}" \
  -var PACKER_KICKSTART="${KICKSTART:?}" \
  -var-file=${MACHINE_TYPE:?} \
  -var-file=${OS_FULL:?} \
  -only="${PACKER_BUILDER:?}" \
  "${TEMPLATE:?}"

# hypervisor specific postprocessing
if (test ${BUILDER:?} == "iso2azure"); then
  # prepare VHD file for azure
  TMP_VHD=/tmp/azure-vhd
  rm -rf ${TMP_VHD}
  mkdir -p ${TMP_VHD}/unzipped
  ln -s $(realpath ./boxes/libvirt/${BOX_NAME:?}.box) ${TMP_VHD}/box.tar.gz
  tar -C ${TMP_VHD}/unzipped -xzvf ${TMP_VHD}/box.tar.gz
  VHD=./boxes/azure/${BOX_NAME:?}.vhd
  mkdir -p $(dirname ${VHD:?})
  rm -f ${VHD:?}
  VBoxManage clonehd ${TMP_VHD}/unzipped/*vmdk ${VHD:?} --format VHD --variant Fixed
  rm -rf ${TMP_VHD}
else
  # vagrant add box
  mkdir -p ./boxes/${BUILDER:?}
  vagrant box add -f --name ${BOX_NAME:?} ./boxes/${BUILDER:?}/${BOX_NAME:?}.box
fi

# in case we build a VirtualBox image outside of Jenkins, also make the box available for libvirt builder
[ $? -eq 0 ] && [ ! -z ${JENKINS_URL} ] && exit 0
[ $? -eq 0 ] && [ ${BUILDER:?} == "virtualbox" ] && vagrant mutate ./boxes/${BUILDER}/${BOX_NAME}.box libvirt

