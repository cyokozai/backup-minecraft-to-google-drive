#!/bin/bash
STATUS=0

set -e
set -o pipefail

readonly datestr=$(date '+%Y%m%d%H%M%S')
readonly DATA_DIR='minecraft/data'
readonly BACKUP_DIR='minecraft/backups'
readonly LOG_FILE=$("minecraft/logs/mcbackup${datestr}.log")
LOG_MSG=''

function log() {
    local level="$1"

    echo "${datestr} [$level] $*" >> ~/$LOG_FILE
    echo "${datestr} [$level] $*" >> $LOG_MSG

    return
}

function copyfile() {
    local src="$1"
    local dest="$2"
    local user="$3"
    
    if [ -d "$src" ]; 
    then
        eval "scp -i ~/.ssh/ed25519 -p 22 $user@denkettle:~/$src ~/$dest/backup-${datestr}"
    else
        log ERROR "File $src does not exist"
        STATUS=1
    fi

    return
}

function compressfile() {
    local src="$1"

    eval "tar czf /backup/backup-${datestr}.tar.gz $src/backup-${datestr}"

    if [ $? -ne 0 ]
    then
        log ERROR "Failed to compress $src"
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
if [ ! -d "~/${LOG_FILE}" ]; 
then
    mkdir -p ~/minecraft
    mkdir -p ~/minecraft/backups
    mkdir -p ~/minecraft/logs
    touch "~/${LOG_FILE}"
fi

log INFO "Starting backup"
cd

# Copy files
copyfile DATA_DIR BACKUP_DIR 'cyokozai'

# Compress files
compressfile BACKUP_DIR

# Delete old files
deletefile "${BACKUP_DIR}/backup-"

# Send mail
log INFO "Backup finished with status ${STATUS}"

if [ ${STATUS} -ne 0 ]
then
    SUBJECT=$(echo -e "[ERROR] cms backup report")
else
    SUBJECT=$(echo -e "[INFO] cms backup report")
fi

echo "$(cat ${LOG_MSG})" | mailx -s "${SUBJECT}" "yourmailaddress"

# Exit with status
exit ${STATUS}