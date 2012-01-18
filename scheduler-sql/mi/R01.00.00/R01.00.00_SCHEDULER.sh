#!/bin/bash

. ../../functions.sh

runScript R01.00.00_SCHEDULER.sql

( cd ../../src && ./all-proc.sh )

runScript R01.00.00_SCHEDULER_DML.sql

exit $?
