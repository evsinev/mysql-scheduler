. ../../functions.sh

(cd ../../db && ./create_database.sh )

(cd ../../src/ut && ./ut-proc.sh )

die "Error creating database"

runScript ut-sched.sql

exit $?
