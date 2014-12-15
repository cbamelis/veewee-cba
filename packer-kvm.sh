#!/bin/bash
CMD="packer build -only=qemu"
test -z ${JENKINS_URL} || CMD="${CMD} -force -machine-readable -var HEADLESS=true"
${CMD} $@
