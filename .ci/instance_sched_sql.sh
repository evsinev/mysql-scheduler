#!/bin/bash

# these variables could be set by MI scripts early
mi_version=${mi_version:-01.00.00}
run_routines=${run_routines:-false}


# main MI options
mi_user=root
mi_port=3306
mi_password=1234        # temporary password for schema owners
use_pam=true            # use external authentication
mi_root_password=charpa # for no PAM installation
sleep_interval=0

# java users
java_sched=java_sched
host_prod_sched=(localhost)

# database systems
db_sched=sched

# pass to store passwords file, check permissions for mysql55 and mi users
passwords_file="pwd"
