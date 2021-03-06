#!/usr/bin/env bash
#######################################################################
# PackageEvaluator
# https://github.com/IainNZ/PackageEvaluator.jl
# (c) Iain Dunning 2015
# Licensed under the MIT License
#######################################################################
# This script launches the Vagrant VMs in parallel, because all the
# work happens during provisioning. Afterwards, it tears them down.
# Based off of
#  http://server.dzone.com/articles/parallel-provisioning-speeding
# Can either run two or four machines in parallel

rm -rf ./0.3*
rm -rf ./0.4*

parallel_provision() {
    while read box; do
        echo "Provisioning '$box'. Output will be in: $box.out.txt" 1>&2
        echo $box
    done | xargs -P 4 -I"BOXNAME" \
        sh -c 'vagrant provision BOXNAME >BOXNAME.out.txt 2>&1 || echo "Error Occurred: BOXNAME"'
}

if [ "$1" == "two" ]
then
    vagrant up --no-provision all03
    vagrant up --no-provision all04

    # Provision in parallel
    cat <<EOF | parallel_provision
all03
all04
EOF

else
    vagrant up --no-provision halfAL03
    vagrant up --no-provision halfMZ03
    vagrant up --no-provision halfAL04
    vagrant up --no-provision halfMZ04

    # Provision in parallel
    cat <<EOF | parallel_provision
halfAL03
halfMZ03
halfAL04
halfMZ04
EOF

fi

# OK, we're done! Teardown VMs
vagrant destroy -f
