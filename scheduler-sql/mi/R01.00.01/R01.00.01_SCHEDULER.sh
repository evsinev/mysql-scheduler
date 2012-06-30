#!/bin/bash

. ../../functions.sh

runScript R01.00.01_SCHEDULER.sql

( cd ../../src && ./all-proc.sh )

runScript R01.00.01_SCHEDULER_DML.sql

exit $?
