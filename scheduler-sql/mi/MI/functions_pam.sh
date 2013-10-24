#!/bin/bash

logInfo() {
    # or tts -s
    which tput > /dev/null 2>&1 && test -t 0 && tput setaf 2 # green
    echo $1
    which tput > /dev/null 2>&1 && test -t 0 && tput sgr0
    which logger > /dev/null 2>&1 && logger "$USER INFO: $1"
}

logError() {
    which tput > /dev/null 2>&1 && test -t 0 && tput setaf 1 # red
    echo $1
    which tput > /dev/null 2>&1 && test -t 0 && tput sgr0
    which logger > /dev/null 2>&1 && logger "$USER ERROR: $1"
}

logWarn() {
    which tput > /dev/null 2>&1 && test -t 0 && tput setaf 3 # yellow
    echo $1
    which tput > /dev/null 2>&1 && test -t 0 && tput sgr0
    which logger > /dev/null 2>&1 && logger "$USER WARN: $1"
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
    aFirst=$1
    aScript=${aFirst##*/*/}

    aUser=$2
    aDatabase=$3
    if [ -f "$aFirst" ]; then
      mkdir -p target
      logInfo "Installing $aScript to $aUser@localhost:$mi_port/$aDatabase ..."
      cat $aFirst | \
        sed s/\${db_sched}/$db_sched/g | \
        sed s/\${mi_password}/$mi_password/g | \
        sed s/\${sleep_interval}/$sleep_interval/g | \
        tee target/$aScript | \
        mysql --default-character-set=utf8 --protocol=TCP -h localhost --port $mi_port -b -vv \
          -u $aUser -p$mi_password $aDatabase --show-warnings --comments > target/$aScript.log
    fi

    die "can not process $aScript"
}

runGrants() {
    aFirst=$1
    aScript=${aFirst##*/*/}

    aUser=$2
    aDatabase=$3

	aGrantUser=$4
	aGrantHost=$5
	
    if [ -f "$aFirst" ]; then
      mkdir -p target
      logInfo "Granting $aScript from $aUser@localhost:$mi_port/$aDatabase to $aGrantUser@$aGrantHost ..."
      cat $aFirst | \
        sed s/\${db_sched}/$db_sched/g | \
        sed s/\${aDatabase}/$aDatabase/g | \
        sed s/\${grant_user}/$aGrantUser/g | \
        sed s/\${grant_host}/$aGrantHost/g | \
        sed s/\${mi_password}/$mi_password/g | \
        sed s/\${sleep_interval}/$sleep_interval/g | \
        tee target/$aScript | \
        mysql --default-character-set=utf8 --protocol=TCP -h localhost --port $mi_port -b -vv \
          -u $aUser -p$mi_password $aDatabase --show-warnings --comments > target/$aScript.log
    fi

    die "can not process $aScript"
}

runRoot() {
    aFirst=$1
    aScript=${aFirst##*/*/}

    if [ -f "$aFirst" ]; then
      mkdir -p target
      logInfo "Installing $aScript to localhost:$mi_port ..."
      cat $aFirst | \
        sed s/\${db_sched}/$db_sched/g | \
        sed s/\${grant_user}/$aGrantUser/g | \
        sed s/\${grant_host}/$aGrantHost/g | \
        sed s/\${mi_password}/$mi_password/g | \
        sed s/\${sleep_interval}/$sleep_interval/g | \
        tee target/$aScript | \
        mysql --default-character-set=utf8 --protocol=TCP -h localhost --port $mi_port -b -vv \
          -u $mi_user -p$mi_root_password mysql --show-warnings --comments > target/$aScript.log
    fi

    die "can not process $aScript"
}

runRootPam() {
    aFirst=$1
    aScript=${aFirst##*/*/}

    if [ -f "$aFirst" ]; then
      logWarn "Prepare to enter $USER password and press ENTER to continue ..." && read
      mkdir -p target
      logInfo "Installing $aScript to localhost:$mi_port ..."
      cat $aFirst | \
        sed s/\${db_sched}/$db_sched/g | \
        sed s/\${mi_password}/$mi_password/g | \
        sed s/\${sleep_interval}/$sleep_interval/g | \
        tee target/$aScript | \
        mysql --default-character-set=utf8 --protocol=TCP -h localhost --port $mi_port -b -vv \
          -u $mi_user mysql --show-warnings --comments > target/$aScript.log
    fi

    die "can not process $aScript"
}

runChangePassword() {
    rm -fr target/$passwords_file.log
    aFirst=$1
    aScript=${aFirst##*/*/}

    if [ -f "$aFirst" ]; then
      mkdir -p target
      logInfo "Installing $aScript to localhost:$mi_port ..."
      cat $aFirst | \
        sed s/\${mi_password}/$mi_password/g | \
        sed s/\${db_sched}/$db_sched/g | \
        sed s/\${sleep_interval}/$sleep_interval/g | \
        mysql --default-character-set=utf8 --protocol=TCP -h localhost --port $mi_port -b -vv \
          -u $mi_user -p$mi_root_password mysql --show-warnings --comments | grep "###" > target/$passwords_file.log
    fi

    if [ ${mi_version//./} -eq "010000" ]; then
        rm -fr target/create_java_users.sql.log
        rm -fr target/create_java_users.sql
        aScript=create_java_users.sql
        mkdir -p target
        logInfo "Creating java users localhost:$mi_port ..."
        cat /dev/null > target/$aScript
        for t_host_prod_sched in ${host_prod_sched[@]}
        do
          echo "grant usage on *.* to '$java_sched'@'$t_host_prod_sched';" >> target/$aScript;
        done

        mysql --default-character-set=utf8 --protocol=TCP -h localhost --port $mi_port -b -vv \
              -u $mi_user -p$mi_root_password mysql --show-warnings --comments > target/$aScript.log < target/$aScript        
    fi

    die "can not process $aScript"
}

runChangePasswordPam() {
    rm -fr target/$passwords_file.log
    aFirst=$1
    aScript=${aFirst##*/*/}

    if [ -f "$aFirst" ]; then
      logWarn "Prepare to enter $USER password and press ENTER to continue ..." && read
      mkdir -p target
      logInfo "Installing $aScript to localhost:$mi_port ..."
      cat $aFirst | \
        sed s/\${mi_password}/$mi_password/g | \
        sed s/\${db_sched}/$db_sched/g | \
        sed s/\${sleep_interval}/$sleep_interval/g | \
        mysql --default-character-set=utf8 --protocol=TCP -h localhost --port $mi_port -b -vv \
          -u $mi_user mysql --show-warnings --comments | grep "###" > target/$passwords_file.log
    fi

    if [ ${mi_version//./} -eq "010000" ]; then
        rm -fr target/create_java_users.sql.log
        rm -fr target/create_java_users.sql
        aScript=create_java_users.sql
        logWarn "Prepare to enter $USER password and press ENTER to continue ..." && read
        mkdir -p target
        logInfo "Creating java users localhost:$mi_port ..."
        cat /dev/null > target/$aScript
        for t_host_prod_sched in ${host_prod_sched[@]}
        do
          echo "grant usage on *.* to '$java_sched'@'$t_host_prod_sched';" >> target/$aScript;
        done

        mysql --default-character-set=utf8 --protocol=TCP -h localhost --port $mi_port -b -vv \
              -u $mi_user mysql --show-warnings --comments > target/$aScript.log < target/$aScript        
    fi

    die "can not process $aScript"
}

catPasswords()
{
    while IFS=$'\t' read col1 col2 col3
    do
      echo "update mysql.user set password = '$col3' where host = 'localhost' and user = '$col2'; " >> $1
    done <  $2
}

runRestorePasswords()
{
    aScript=restore_passwords.sql
    mkdir -p target
    logInfo "Restoring passwords to localhost:$mi_port ..."
    cat /dev/null > target/$aScript
    catPasswords target/$aScript target/$passwords_file.log
    mysql --default-character-set=utf8 --protocol=TCP -h localhost --port $mi_port -b -vv \
      -u $mi_user -p$mi_root_password mysql --show-warnings --comments > target/$aScript.log < target/$aScript        
    rm -fr target/$passwords_file.log
    rm -fr target/restore_passwords.sql.log
    rm -fr target/restore_passwords.sql

    die "can not process $aScript"
}

runRestorePasswordsPam()
{
    aScript=restore_passwords.sql
    logWarn "Prepare to enter $USER password and press ENTER to continue ..." && read
    mkdir -p target
    logInfo "Restoring passwords to localhost:$mi_port ..."
    cat /dev/null > target/$aScript
    catPasswords target/$aScript target/$passwords_file.log
    mysql --default-character-set=utf8 --protocol=TCP -h localhost --port $mi_port -b -vv \
      -u $mi_user mysql --show-warnings --comments > target/$aScript.log < target/$aScript        
    rm -fr target/$passwords_file.log
    rm -fr target/restore_passwords.sql.log
    rm -fr target/restore_passwords.sql

    die "can not process $aScript"
}
