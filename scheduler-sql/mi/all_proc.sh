#!/bin/bash

export mi_version=00.00.00
export run_routines=true

(cd MI && ./run_MI_proc.sh)

exit $?