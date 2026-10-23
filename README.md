# mysql-scheduler

A task scheduler for MariaDB/MySQL. Tasks are rows in the `scheduled_tasks` table: each one holds an SQL
statement and a schedule. A Java process polls the database, picks the tasks that are due and runs each of
them in its own thread through the `set_task_running` stored procedure, which executes the statement with
`prepare`/`execute` and computes the next run time.

Task status (`scheduled_tasks.exec_status`):

```
C (completed) / F (failed)  →  S (starting)  →  R (running)  →  C  or  F
```

Every transition is also written to `scheduled_task_logs`, including the error message of a failed run.

## Quick start

Download `scheduler-<version>.jar` from [GitHub Releases](https://github.com/evsinev/mysql-scheduler/releases)
and run it with Java 21:

```bash
URL=jdbc:mariadb://db-host:3306/sched PASSWORD=... java -jar scheduler-2.0-1.jar
```

or build the Docker image from `docker/Dockerfile` (it downloads the release jar; `URL` defaults to
`jdbc:mariadb://mysql:3306/sched`):

```bash
docker build -t mysql-scheduler docker/
docker run -e URL=jdbc:mariadb://db-host:3306/sched -e PASSWORD=... mysql-scheduler
```

The scheduler stops on SIGTERM: it runs the shutdown queries and waits up to `WAIT_SHUTDOWN_SECONDS` for the
running tasks.

## Configuration

Each parameter is looked up in this order: Java system property (`-DURL=...`), environment variable,
properties file given by `-DCONFIG_FILE=/path/to/file`, default.

| Parameter | Default | Description |
|---|---|---|
| `URL` | `jdbc:mariadb://localhost:3306/sched` | JDBC URL (MariaDB Connector/J) |
| `USERNAME` | `java_sched` | user that runs the tasks |
| `PASSWORD` | `123java_sched123` | its password |
| `PRIVILEGED_USERNAME` | `root` | user for startup and shutdown queries |
| `PRIVILEGED_PASSWORD` | empty | its password |
| `MAX_THREADS` | `40` | maximum number of tasks running at the same time (and of pool connections) |
| `MAX_IDLE` | `15` | maximum number of idle pool connections |
| `SLEEP_MS` | `20000` | pause between polls of the database |
| `WAIT_SHUTDOWN_SECONDS` | `900` | how long to wait for running tasks on shutdown |

Startup and shutdown queries are read from system properties or environment variables only (not from
`CONFIG_FILE`): `STARTUP_QUERY_0`, `STARTUP_QUERY_1`, ... and `SHUTDOWN_QUERY_0`, ...; numbering starts at 0
and stops at the first missing number. They run with autocommit as `PRIVILEGED_USERNAME`. A failed startup
query stops the scheduler, a failed shutdown query is only logged.

## Database setup

The schema, stored procedures and grants are installed with the MI scripts in `scheduler-sql/mi`. They read
the instance settings from `~/env/instance_sched.sh`:

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

Then:

```bash
cd scheduler-sql/mi
./all_mi.sh      # all releases R01.00.00, R01.00.01, ... with stored procedures and grants
./all_proc.sh    # stored procedures and grants only, tables are not touched
```

The scripts connect over TCP to `localhost` as the schema owner `sched@localhost`. The Java user
(`java_sched` on every host from `host_prod_sched`) must exist beforehand; it gets `EXECUTE` on
`create_collections` and the `get*`/`set*` procedures and `SELECT` on `mysql.proc`.

## Scheduling tasks

```sql
insert into scheduled_tasks(task_name, task_description, task_definition,
                            task_start_date, retry_interval, schedule_strategy, exec_next_date)
     values ('purge_old_logs', 'Deletes logs older than 30 days',
             'call app.purge_old_logs(30)',
             '2026-01-01 03:00:00', '1D', 'S', '2026-01-01 03:00:00');
```

- `task_definition` — one SQL statement; it runs with the rights of the schema owner (the definer of
  `set_task_running`), not of `java_sched`.
- `exec_next_date` — the first run; a task with an empty `exec_next_date` never runs.
- `retry_interval` — a number and a unit:

  | Unit | Meaning | Example |
  |---|---|---|
  | `MI` | minutes | `10MI` |
  | `HH` | hours | `2HH` |
  | `D` | days | `1D` |
  | `M` | months | `1M` |
  | `ME` | months, at 23:00 on the last day of the month | `1ME` |
  | `Y` | years | `1Y` |

- `schedule_strategy`:
  - `S` (default) — fixed grid from `task_start_date`: the next run is the first grid point after the end of
    the current one, so a long run skips grid points instead of shifting the schedule;
  - `E` — the interval is counted from the end of the previous run.

A failed task keeps its `exec_next_date`, so it is retried on every poll (every `SLEEP_MS`) until it
succeeds or is fixed.

Pause and resume all tasks:

```sql
call pause_scheduler(600);   -- stop picking new tasks, wait up to 600 s for running ones
call continue_scheduler();
```

`pause_scheduler` fails with `time.exceeded` if the running tasks do not finish in time; the scheduler stays
paused anyway.

## Upgrading from 1.0-x

- Java 21 is required.
- The driver is MariaDB Connector/J. Old `jdbc:mysql:` URLs are rewritten to `jdbc:mariadb:` at startup, and
  MySQL Connector/J 5.1 options in them (`logger`, `noAccessToProcedureBodies`, ...) are ignored.
- TLS options are not translated one to one: `useSSL=true` becomes `sslMode=verify-full` and
  `verifyServerCertificate=false` is not taken into account, so set `sslMode` (and the trust store)
  explicitly.

## Build

Requires Java 21 and Maven 3.9+.

```bash
cd scheduler
mvn clean verify
java -jar target/scheduler-*.jar
```

Development checks (live run against MariaDB, OWASP scan, review) are described in [CLAUDE.md](CLAUDE.md).

## Release

Push a tag `mysql-scheduler-<major>.<minor>-<build>` on master, e.g. `mysql-scheduler-2.0-1`. GitHub Actions
builds the project with this version and attaches `scheduler-<version>.jar` and its `.sha256` to the GitHub
release. The version in `pom.xml` stays `-SNAPSHOT`.

```bash
git tag mysql-scheduler-2.0-1
git push origin mysql-scheduler-2.0-1
```
