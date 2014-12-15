#!/bin/bash -l
CMD="packer build -only=virtualbox-iso"
test -z ${JENKINS_URL} || CMD="${CMD} -force -machine-readable -var HEADLESS=true"
${CMD} $@
