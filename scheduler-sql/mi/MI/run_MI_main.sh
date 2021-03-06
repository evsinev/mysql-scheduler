#!/bin/bash

. ~/env/instance_sched.sh
. ./functions_pam.sh

if $use_pam ; then
	runChangePasswordPam change_passwords.sql
else
	runChangePassword change_passwords.sql
fi

logWarn "Production installation start"
(cd ../R"$mi_version" && runScript R"$mi_version"_SCHEDULER.sql $db_sched $db_sched)
if $run_routines ; then
	(cd ../../src && runScript all-proc.sql $db_sched $db_sched)

	for t_host_prod_sched in ${host_prod_sched[@]}
	do
	  (cd ../../java_users && runGrants java_sched.sql $db_sched $db_sched $java_sched $t_host_prod_sched)
	done

fi
(cd ../R"$mi_version" && runScript R"$mi_version"_SCHEDULER_DML.sql $db_sched $db_sched)

if $use_pam ; then
	runRestorePasswordsPam
else
	runRestorePasswords
fi

exit $?
