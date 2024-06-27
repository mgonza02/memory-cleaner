#!/bin/bash

# check if has root permission
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi
# echo welcome message
echo "clean script installer"

DESTINATION_FOLDER="/usr/bin/clean"

LOG_FILE="/var/log/memoryClean.log"

# function to write log to /var/log/memoryClean.log file with datetime and message
log() {
    # echo  date - hostname - message
    echo "$(date) - $(hostname) - $1" >>$LOG_FILE

}

# check received parameters i o u
if [ "$1" == "i" ]; then
    # install
    log "installing..."
    CLEAN_SCRIPT="sync && echo 3 > /proc/sys/vm/drop_caches && echo $(date) - $(hostname) - memory cleaned >>$LOG_FILE"

    # create  destination folder
    mkdir -p $DESTINATION_FOLDER

    # create the script
    echo $CLEAN_SCRIPT >$DESTINATION_FOLDER/clean.sh

    chmod +x $DESTINATION_FOLDER/clean.sh

    # check if clean is already definned in crontab
    if ! crontab -l | grep -q "clean.sh"; then
        # add the script to crontab every 6 hours
        (
            crontab -l
            echo "0 */6 * * * $DESTINATION_FOLDER/clean.sh > $LOG_FILE 2>&1"
        ) | crontab -

    else
        log "clean.sh already defined in crontab"
    fi
    # print done
    log "done"
elif [ "$1" == "u" ]; then
    # uninstall
    log "uninstalling..."
    # uninstall from crontab
    crontab -l | grep -v "clean.sh" | crontab -
    # remove the folder
    rm -rf $DESTINATION_FOLDER
    # log done
    log "done"
else
    echo "invalid action, use i for install or u for uninstall"
fi
