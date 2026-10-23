#!/usr/bin/env bash
# Live test: MariaDB in docker, schema installed with the MI scripts, the scheduler jar runs real tasks.
# Usage: scripts/live-test.sh [jar]   (default: scheduler/target/scheduler-*.jar, build it first)
# Env: MARIADB_IMAGE (default mariadb:10.6.18), DB_PORT (default 33306), KEEP_DB=1 keeps the container.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
JAR="${1:-$(ls "$ROOT"/scheduler/target/scheduler-*.jar 2>/dev/null | head -1)}"
[ -f "$JAR" ] || { echo "jar not found, run: (cd scheduler && mvn -B verify)" >&2; exit 2; }
JAR="$(cd "$(dirname "$JAR")" && pwd)/$(basename "$JAR")"
IMAGE="${MARIADB_IMAGE:-mariadb:10.6.18}"
PORT="${DB_PORT:-33306}"
NAME="sched-live-test-$$"
WORK="$(mktemp -d)"
ROOT_PASSWORD=charpa
JAVA_PASSWORD=123java_sched123

cleanup() {
  [ "${KEEP_DB:-}" = 1 ] || docker rm -f "$NAME" > /dev/null 2>&1 || true
  rm -rf "$WORK"
}
trap cleanup EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
sql() { docker exec "$NAME" mysql -uroot -p"$ROOT_PASSWORD" -N -B sched -e "$1" 2> /dev/null; }

echo "== starting $IMAGE as $NAME on 127.0.0.1:$PORT"
# MI scripts log in as sched@localhost over TCP, which needs name resolution
docker run -d --name "$NAME" -e MARIADB_ROOT_PASSWORD="$ROOT_PASSWORD" -p "127.0.0.1:$PORT:3306" \
  "$IMAGE" --skip-name-resolve=0 > /dev/null
# over TCP: the entrypoint first runs a temporary server with --skip-networking
ready() { docker exec "$NAME" mysql --protocol=TCP -h 127.0.0.1 -uroot -p"$ROOT_PASSWORD" -e 'select 1' > /dev/null 2>&1; }
for _ in $(seq 1 90); do ready && break; sleep 1; done
ready || fail "MariaDB did not start"

echo "== installing schema with MI scripts"
cat > "$WORK/instance_sched.sh" <<'EOF'
#!/bin/bash
mi_version=${mi_version:-01.00.00}
run_routines=${run_routines:-false}
mi_user=root
mi_port=3306
mi_password=1234
use_pam=false
mi_root_password=charpa
sleep_interval=0
java_sched=java_sched
host_prod_sched=(localhost %)
db_sched=sched
passwords_file="pwd"
EOF
docker exec "$NAME" mkdir -p /root/env /work
docker cp "$WORK/instance_sched.sh" "$NAME:/root/env/instance_sched.sh"
docker cp "$ROOT/scheduler-sql" "$NAME:/work/"
docker exec "$NAME" mysql -uroot -p"$ROOT_PASSWORD" -e \
  "create user java_sched@'%' identified by '$JAVA_PASSWORD'; create user java_sched@localhost identified by '$JAVA_PASSWORD';
   create user java_nopass@'%'; grant execute on sched.* to java_nopass@'%'; grant select on mysql.proc to java_nopass@'%';"
docker exec -e HOME=/root -w /work/scheduler-sql/mi "$NAME" bash ./all_mi.sh > "$WORK/mi.log" 2>&1 || true
if grep -q "ERROR" "$WORK/mi.log"; then
  grep -v "Using a password" "$WORK/mi.log" >&2
  fail "MI scripts reported errors"
fi
[ "$(sql "select count(*) from information_schema.routines where routine_schema = 'sched'")" -ge 13 ] \
  || fail "stored procedures are not installed"
sql "create table test_hits(source varchar(32), ts datetime)"

# $1 — run name, the rest — extra java args; the environment is set by the caller
run_scheduler() {
  local run=$1; shift
  sql "delete from scheduled_task_logs; delete from scheduled_tasks; delete from test_hits;
       insert into scheduled_tasks(task_name, task_definition, task_start_date, retry_interval, schedule_strategy, exec_next_date)
       values ('ok_task',   'insert into sched.test_hits values (''task'', now())', now(), '1MI', 'S', now()),
              ('fail_task', 'call sched.no_such_proc()',                           now(), '1MI', 'S', now()),
              ('slow_task', 'do sleep(5)',                                         now(), '1MI', 'S', now())"

  echo "== run '$run'"
  java "$@" -jar "$JAR" > "$WORK/$run.log" 2>&1 &
  local pid=$!
  local done=""
  for _ in $(seq 1 60); do
    kill -0 "$pid" 2> /dev/null || { cat "$WORK/$run.log" >&2; fail "$run: scheduler exited before tasks ran"; }
    if [ "$(sql "select count(*) from scheduled_tasks where task_name = 'ok_task' and exec_status = 'C' and exec_end_date is not null")" = 1 ] \
       && [ "$(sql "select count(*) from scheduled_tasks where task_name = 'fail_task' and exec_status = 'F'")" = 1 ] \
       && [ "$(sql "select count(*) from scheduled_tasks where task_name = 'slow_task' and exec_status = 'R'")" = 1 ]; then
      done=1; break
    fi
    sleep 1
  done
  kill -TERM "$pid"
  # slow_task is still running here: shutdown must wait for it, but not forever
  for _ in $(seq 1 30); do kill -0 "$pid" 2> /dev/null || break; sleep 1; done
  if kill -0 "$pid" 2> /dev/null; then
    kill -KILL "$pid"; wait "$pid" || true
    cat "$WORK/$run.log" >&2; fail "$run: scheduler did not stop in 30 s after SIGTERM"
  fi
  local rc=0
  wait "$pid" || rc=$?
  [ -n "$done" ] || { cat "$WORK/$run.log" >&2; fail "$run: tasks did not reach C/F/R in 60 s"; }
  [ "$rc" = 143 ] || { cat "$WORK/$run.log" >&2; fail "$run: exit code $rc, expected 143 (SIGTERM)"; }

  [ "$(sql "select count(*) from test_hits where source = 'task'")" -ge 1 ] || fail "$run: ok_task did not run its SQL"
  [ "$(sql "select count(*) from scheduled_tasks where task_name = 'ok_task' and exec_next_date > now()")" = 1 ] \
    || fail "$run: ok_task has no next run in the future"
  [ "$(sql "select count(*) from scheduled_task_logs l join scheduled_tasks t on t.stsk_id = l.stsk_stsk_id
            where t.task_name = 'fail_task' and l.exec_status = 'F' and l.error_message like '%no_such_proc%'")" -ge 1 ] \
    || fail "$run: fail_task has no error message in scheduled_task_logs"
  [ "$(sql "select count(*) from test_hits where source = 'startup'")" = 1 ] || fail "$run: startup query did not run"
  [ "$(sql "select count(*) from test_hits where source = 'shutdown'")" = 1 ] || fail "$run: shutdown query did not run"
  [ "$(sql "select count(*) from scheduled_tasks where task_name = 'slow_task' and exec_status = 'C'")" = 1 ] \
    || fail "$run: slow_task running at SIGTERM was not completed"
  if grep -q "Cannot stop executor" "$WORK/$run.log"; then fail "$run: executor did not stop cleanly"; fi
  echo "   ok"
}

# 1. Old-style config: jdbc:mysql URL with Connector/J 5.1 options, everything from the environment
URL="jdbc:mysql://127.0.0.1:$PORT/sched?logger=Slf4JLogger&noAccessToProcedureBodies=true&useInformationSchema=true&autoReconnect=false&characterEncoding=utf8" \
PRIVILEGED_PASSWORD="$ROOT_PASSWORD" SLEEP_MS=1000 WAIT_SHUTDOWN_SECONDS=10 \
STARTUP_QUERY_0="insert into sched.test_hits values ('startup', now())" \
SHUTDOWN_QUERY_0="insert into sched.test_hits values ('shutdown', now())" \
  run_scheduler env-mysql-url
grep -q "replaced jdbc:mysql: with jdbc:mariadb:" "$WORK/env-mysql-url.log" || fail "env-mysql-url: URL was not rewritten"

# 2. Everything from CONFIG_FILE, including startup and shutdown queries and an empty PASSWORD
cat > "$WORK/scheduler.properties" <<EOF
URL=jdbc:mariadb://127.0.0.1:$PORT/sched
USERNAME=java_nopass
PASSWORD=
PRIVILEGED_PASSWORD=$ROOT_PASSWORD
SLEEP_MS=1000
WAIT_SHUTDOWN_SECONDS=10
STARTUP_QUERY_0=insert into sched.test_hits values ('startup', now())
SHUTDOWN_QUERY_0=insert into sched.test_hits values ('shutdown', now())
EOF
run_scheduler config-file -DCONFIG_FILE="$WORK/scheduler.properties"

echo "== all live tests passed"
