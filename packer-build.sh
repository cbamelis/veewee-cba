#!/bin/bash

PATH_JSON=./templates
PATH_OS=${PATH_JSON}/os
PATH_MACHINES=${PATH_JSON}/machines
PATH_KICKSTART=./kickstart
DEFAULT_MACHINE_TYPE=single

function help_templates() {
  local MSG=$1
  echo -e "${MSG}"
  for FILE in ${PATH_JSON}/*.json; do
    FILE_CONTENT=$(cat ${FILE} | grep -i description | cut -d ":" -f 2 | sed 's/"//g')
    printf "    %-40s" ${FILE}
    echo ${FILE_CONTENT%\,}
  done
  return 1
}

function help_machines() {
  local MSG=$1
  echo -e "${MSG}"
  for FILE in ${PATH_MACHINES}/*.json; do
    FILE_CONTENT=$(cat ${FILE} | sed ':a;N;$!ba;s/\n/ /g' )
    printf "    %-40s" ${FILE}
    echo ${FILE_CONTENT}
  done
  return 1
}

function help_kickstart() {
  local MSG=$1
  echo -e "${MSG}"
  for FILE in ${PATH_KICKSTART}/*.cfg; do
    FILE_CONTENT=$(cat ${FILE} | head -1 )
    printf "    %-40s" ${FILE}
    echo ${FILE_CONTENT}
  done
  return 1
}

function help_os() {
  local MSG=$1
  echo -e "${MSG}"
  for FILE in ${PATH_OS}/*.json; do
    FILE_CONTENT=$(cat ${FILE} | grep "ISO_FILENAME" | sed 's/"//g' | sed 's/^\w+//')
    printf "    %-40s" ${FILE}
    echo "# ${FILE_CONTENT%\,}"
  done
  return 1
}

function help_hyperv() {
  local MSG=$1
  echo -e "${MSG}"
  echo    "    virtualbox"
  echo    "    vmware"
  echo    "    qemu"
  return 1
}

function help() {
  local MSG=$1
  echo -e "${MSG}"
  echo "Usage:"
  echo "  $0 <packer_template> <kickstart> [<machine_type> <operating_system> <hypervisor>]"
  echo ""
  echo "  The last 3 parameters can be omitted in case of running $0 from Jenkins"
  echo "    - <machine_type> will default to \"${DEFAULT_MACHINE_TYPE}\""
  echo "    - <operating_system> and <hypervisor> will be parsed from the Jenkins JOB_NAME"
  echo "      which is assumed to follow naming convention <operating_system>-<hypervisor>"
  echo ""
  help_templates "\n  <packer_template> is a JSON packer template; currently supported:"
  help_kickstart "\n  <kickstart> is a kickstart/preseed file containing all answers for unattended OS installation; currently supported:"
  help_machines  "\n  <machine_type> is a JSON file with hardware description; currently supported:"
  help_os        "\n  <operating_system> is a JSON file with Operating System description; currently supported:"
  help_hyperv    "\n  <hypervisor> is the name of the hypervisor (packer builder) to use; currently supported:"
  echo ""
  exit -1
}

# check command line parameters; print help if incorrect
[ $# -lt 2 ] && help "\nNot enough command line parameters!\n"
[ $# -eq 2 ] && [ -z ${JOB_NAME} ] && help "\nNot enough command line parameters (or Jenkins variable JOB_NAME not found)!\n"
[ $# -gt 5 ] && help "\nToo much command line parameters!\n"

# verify parameter packer_template
TEMPLATE=$1
test -f ${TEMPLATE} || TEMPLATE=${PATH_JSON}/${TEMPLATE}.json
test -f ${TEMPLATE} || help_templates "\nUnable to find the given packer_template (\"${TEMPLATE}\")" || exit -1
shift

# verify parameter kickstart
KICKSTART=$1
test -f ${PATH_KICKSTART}/${KICKSTART} || KICKSTART=${KICKSTART}.cfg
test -f ${PATH_KICKSTART}/${KICKSTART} || help_kickstart "\nUnable to find the given kickstart (\"${KICKSTART}\")" || exit -1
shift

# verify parameter machine_type
[ $# -eq 0 ] && MACHINE_TYPE=${DEFAULT_MACHINE_TYPE}
[ $# -gt 0 ] && MACHINE_TYPE=$1 && shift
test -f ${MACHINE_TYPE} || MACHINE_TYPE=${PATH_MACHINES}/${MACHINE_TYPE}.json
test -f ${MACHINE_TYPE} || help_machines "\nUnable to find the given machine_type (\"${MACHINE_TYPE}\")" || exit -1

# parameters operating_system and hypervisor
if ([ $# -eq 0 ] && test ! -z ${JOB_NAME}); then
  # fetch os and hypervisor from jenkins job name
  JOB_NAME_AS_ARRAY=(${JOB_NAME//-/ })  # replace dash by space; split into array
  TOKEN_COUNT=${#JOB_NAME_AS_ARRAY[@]}
  LAST_TOKEN_INDEX=$(expr ${TOKEN_COUNT} - 1)
  PACKER_PROVIDER=${JOB_NAME_AS_ARRAY[${LAST_TOKEN_INDEX}]}
  CMD_EXTRA=" -force -machine-readable -var HEADLESS=true"
  OS=${JOB_NAME%-${PACKER_PROVIDER}}
else
  OS=$1
  PACKER_PROVIDER=$2
  JOB_NAME=${OS}-${PACKER_PROVIDER}
fi

# verify parameter os
VAGRANT_BOX_NAME=${OS}
test -f ${OS} || OS=${PATH_OS}/${OS}.json
test -f ${OS} || help_os "Unable to find the given operating_system (\"${OS}\")" || exit -1

# verify parameter hypervisor
if (test ${PACKER_PROVIDER} == "virtualbox"); then
  PACKER_PROVIDER="virtualbox-iso"
elif (test ${PACKER_PROVIDER} == "vmware"); then
  PACKER_PROVIDER="vmware-iso"
elif (test ${PACKER_PROVIDER} != "qemu"); then
  help_hyperv "Unsupported hypervisor (\"${PACKER_PROVIDER}\")" || exit -1
fi

# extra parameters for automated runs
test ! -z ${JENKINS_URL} && EXTRA="-machine-readable -var HEADLESS=true" || EXTRA=

# packer build
CMD="packer build -force ${EXTRA} -var PACKER_KICKSTART=${KICKSTART} -var-file=${MACHINE_TYPE} -var-file=${OS} -only=${PACKER_PROVIDER} ${TEMPLATE}"
echo ${CMD}
${CMD}

# vagrant add box
[ $? -eq 0 ] && [ ! -z ${JOB_NAME} ] && vagrant box add -f --name ${VAGRANT_BOX_NAME} ./boxes/${JOB_NAME}.box

