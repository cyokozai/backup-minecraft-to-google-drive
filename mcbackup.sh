#!/bin/bash
readonly LOG_FILE='./minecraft/data/logs/mcbackup.log'
STATUS=0
cd /home/*

set -e
set -o pipefail

function copyfile() {
    local src="$1"
    local dest="$2"
    if [ -d "$src" ]; then
        cp "$src" "$dest"
    else
        log ERROR "File $src does not exist"
        STATUS=1
    fi

    return
}

function log() {
    local level="$1"
    shift
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $*" >>$LOG_FILE

    return
}

if [ ! -d "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    log INFO "Starting backup"
fi

log INFO "Starting backup"

