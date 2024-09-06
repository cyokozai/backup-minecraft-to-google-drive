#!/bin/bash
STATUS=0
DEAMON='mcbackup'

set -e
set -o pipefail

sudo mv ./src/mcbackup.sh /usr/local/bin/${DEAMON}
sudo chmod +x /usr/local/bin/${DEAMON}
source ~/.bashrc

CRON_JOB="0 3 * * * ${DEAMON} >> ~/log/${DEAMON}.log 2>&1"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

exit ${STATUS}