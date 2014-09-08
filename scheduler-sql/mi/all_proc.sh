#!/bin/bash

. ~/env/instance_sched.sh
. ./MI/functions_pam.sh

if $use_pam ; then
    setPamPassword
fi

export mi_version=00.00.00
export run_routines=true

(cd MI && ./run_MI_proc.sh)

exit $?