#!/bin/bash

. ~/env/instance_sched.sh
. ./functions_pam.sh

if $use_pam ; then
	for t_host_prod_sched in ${host_prod_sched[@]}
	do
	  (cd ../R"$mi_version" && runRootPam R"$mi_version"_ROOT.sql $java_sched $t_host_prod_sched)
	done
else
	for t_host_prod_sched in ${host_prod_sched[@]}
	do
	  (cd ../R"$mi_version" && runRoot R"$mi_version"_ROOT.sql $java_sched $t_host_prod_sched)
	done
fi

exit $?