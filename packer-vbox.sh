#!/bin/bash -l
PROV=virtualbox
CMD="packer build -only=${PROV}-iso"
test -z ${JENKINS_URL} || CMD="${CMD} -force -machine-readable -var HEADLESS=true"
${CMD} $@ && vagrant box remove -f --provider ${PROV} && vagrant box add -f --provider ${PROV} --box-version ${BUILD_NUMBER-1} $(find ./boxes -iname "*.box")
