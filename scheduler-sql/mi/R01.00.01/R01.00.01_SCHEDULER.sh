#!/bin/bash

export mi_version=01.00.01
export run_routines=true

(cd ../MI && ./run_MI_root.sh)
(cd ../MI && ./run_MI_main.sh)

exit $?
