#!/bin/bash
STATUS=0

set -e
set -o pipefail

. import-env ./.env

readonly datestr=$(date '+%Y%m%d%H%M%S')
readonly DATA_DIR='minecraft/data'
readonly BACKUP_DIR='minecraft/backups'
readonly LOG_FILE="minecraft/logs/mcbackup-${datestr}.log"

function log() {
    local level="$1"

    echo "${datestr} [$level] $*" >> ~/${LOG_FILE}

    return
}

function copyfile() {
    local src="$1"
    local dest="$2"
    local user="$3"
    
    eval "scp -i ~/.ssh/${KEY_NAME} -P ${PORT} -r ${user}@${HOST}:~/${src} ~/$dest/backup-${datestr}"
    
    if [ -d "${src}" ]
    then
        log ERROR "File $src does not exist"
        STATUS=1
    fi

    return
}

function compressfile() {
    local src="$1"

    eval "tar czf ~/${src}/backup-${datestr}.tar.gz ~/${src}/backup-${datestr}"
    rm -rf ~/${src}/backup-${datestr}

    if [ $? -ne 0 ]
    then
        log ERROR "Failed to compress ${src}/backup-${datestr}"
        STATUS=1
    fi

    return
}

function deletefile(){
    CNT=0

    for file in `ls -1t ${1}*`
    do
        CNT=$((CNT+1))
            
        if [ ${CNT} -le 10 ]
        then
            continue
        fi

        eval "rm ${file}"
    done

    return
}

# Main
log INFO "Starting backup"
cd

if [ ! -d "~/${LOG_FILE}" ]; 
then
    touch ~/${LOG_FILE}
fi

# Copy files
copyfile ${DATA_DIR} ${BACKUP_DIR} ${USER}

if [ ${STATUS} -e 0 ]
then
    log INFO "backup-${datestr} copied"
fi

# Compress files
compressfile ${BACKUP_DIR}

if [ ${STATUS} -e 0 ]
then
    log INFO "backup-${datestr}.tar.gz compressed"
fi

# Delete old files
deletefile "~/${BACKUP_DIR}/backup-"

if [ ${STATUS} -e 0 ]
then
    log INFO "Old files deleted"
fi

# Send mail
log INFO "Backup finished with status ${STATUS}"

if [ ${STATUS} -ne 0 ]
then
    SUBJECT=$(echo -e "[ERROR] cms backup report")
else
    SUBJECT=$(echo -e "[INFO] cms backup report")
fi

echo "$(cat ${LOG_FILE})" | mailx -s "${SUBJECT}" ${EMAIL}

# Exit with status
exit ${STATUS}