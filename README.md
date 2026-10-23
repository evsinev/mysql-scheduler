## How to build the project

Requires Java 21 and Maven 3.9+.

```bash
git clone git@github.com:evsinev/mysql-scheduler.git
cd mysql-scheduler/scheduler
mvn clean verify

( cd ../scheduler-sql/mi/UT && ./ut-sched.sh )

java -jar target/scheduler-2.0-1-SNAPSHOT.jar
```

## Database connection

The scheduler uses MariaDB Connector/J. Set `URL` (system property, environment variable or `CONFIG_FILE`),
for example `jdbc:mariadb://localhost:3306/sched`. Old `jdbc:mysql:` URLs are rewritten to `jdbc:mariadb:`
at startup; MySQL Connector/J 5.1 options in them (`logger`, `noAccessToProcedureBodies`, ...) are ignored.
TLS options are not translated one to one: `useSSL=true` becomes `sslMode=verify-full` and
`verifyServerCertificate=false` is not taken into account, so set `sslMode` (and the trust store) explicitly.

## Release

Push a tag `mysql-scheduler-<version>`, e.g. `mysql-scheduler-2.0-1`. GitHub Actions builds the project with
this version and attaches `scheduler-<version>.jar` and its `.sha256` to the GitHub release.

```bash
git tag mysql-scheduler-2.0-1
git push origin mysql-scheduler-2.0-1
```

## Configure master install 

Add to the ~/env/instance_sched.sh

```bash
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
```

