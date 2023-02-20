git clone git@github.com:evsinev/mysql-scheduler.git
cd mysql-scheduler
mvn clean install assembly:single

( cd scheduler-sql/mi/UT && ./ut-sched.sh )

java -jar target/mysql-scheduler-1.0-2-SNAPSHOT-jar-with-dependencies.jar



~/env/instance_sched.sh

#!/bin/bash

# instance name
export user_postfix=
#HOLLAND

# these variables could be set by MI scripts early
mi_version=${mi_version:-01.00.00}
run_routines=${run_routines:-false}

# main MI options
mi_user=root
mi_port=3306
mi_password=1234        # temporary password for schema owners
use_pam=false           # use external authentication
mi_root_password=charpa # for no PAM installation 
sleep_interval=0

# java users
java_sched=java_sched
host_prod_sched=(localhost)

# database systems
db_sched=sched

# pass to store passwords file, check permissions for mysql55 and mi users
passwords_file="pwd"