#!/bin/bash

. ~/env/instance_sched.sh
. ./functions_pam.sh

if $use_pam ; then
	(cd ../R"$mi_version" && runRootPam R"$mi_version"_ROOT.sql)
else
	(cd ../R"$mi_version" && runRoot R"$mi_version"_ROOT.sql)
fi

exit $?