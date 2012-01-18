#!/bin/bash

export SCHED_DB_USERNAME=${SCHED_DB_USERNAME:-sched}
export SCHED_DB_PASSWORD=${SCHED_DB_PASSWORD:-123sched123}
export SCHED_DB_DATABASE=${SCHED_DB_DATABASE:-sched}

export SCHED_DB_ROOT_PASSWORD=${SCHED_DB_ROOT_PASSWORD:-charpa}

export SCHED_DB_HOST=${SCHED_DB_HOST:-localhost}
export SCHED_DB_PORT=${SCHED_DB_PORT:-3306}

logInfo() {
    # or tts -s
    test -t 0 && tput setaf 2 # green
    echo $1
    test -t 0 && tput sgr0
    logger "$USER INFO: $1"
}

logError() {
    test -t 0 && tput setaf 1 # red
    echo $1
    test -t 0 && tput sgr0
    logger "$USER ERROR: $1"
}

logWarn() {
    test -t 0 && tput setaf 3 # yellow
    echo $1
    test -t 0 && tput sgr0
    logger "$USER WARN: $1"
}

die() {
    errorCode=$?
    errorMessage=$1
    
    if [ $errorCode != 0 ] 
    then
        logError ".ERROR.: $errorCode - $errorMessage"
        test -t 0 || exit 1
    fi

    return $errorCode
}


runScript() {

#    die 'Oooops...' # to react on previous fail (like DDL script before DML script)

    aScript=$1

    mkdir -p target
    logInfo "Installing to $SCHED_DB_USERNAME@$SCHED_DB_HOST:$SCHED_DB_PORT/$SCHED_DB_DATABASE $aScript ..."
    cat $aScript | sed s/sched/$SCHED_DB_DATABASE/g | \
        mysql --default-character-set=utf8 --protocol=TCP -h $SCHED_DB_HOST --port $SCHED_DB_PORT -b -vv -u $SCHED_DB_USERNAME -p$SCHED_DB_PASSWORD $SCHED_DB_DATABASE --show-warnings --comments > target/$aScript.log 

    die "can not process $aScript"

    return $?

}

runScriptRoot() {

    aScript=$1

    mkdir -p target
    logWarn "Installing to root@$SCHED_DB_HOST:$SCHED_DB_PORT $aScript ..."
    cat $aScript | sed s/sched/$SCHED_DB_DATABASE/g | \
        mysql --default-character-set=utf8 --protocol=TCP -h $SCHED_DB_HOST --port $SCHED_DB_PORT -b -vv -uroot -p$SCHED_DB_ROOT_PASSWORD --show-warnings --comments > target/$aScript.log

    die "can not process $aScript"

    return $?

}
