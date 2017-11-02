#!/usr/bin/env bash

set -eux

cd "$(dirname "$0")"

export USER=root
export HOME=/root
export MYSQL_PWD=charpa

# instance.sh
mkdir -p ~/env
cp instance_sched_sql.sh ~/env/instance_sched.sh

# clone mysql-scheduler repository
git clone https://github.com/evsinev/mysql-scheduler.git
cd mysql-scheduler

# run mi
cd scheduler-sql/mi
time ./all_mi.sh 2>&1 | grep --line-buffered -v "Using a password on the command line interface can be insecure" || exit 1
