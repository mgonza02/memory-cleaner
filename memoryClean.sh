#!/bin/bash

# check if has root permission
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi
# echo welcome message
echo "clean script installer"

DESTINATION_FOLDER="/usr/bin/clean"

# check received parameters i o u
if [ "$1" == "i" ]; then
    # install
    echo "installing..."

    CLEAN_SCRIPT="sync && echo 3 > /proc/sys/vm/drop_caches"

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
            echo "0 */6 * * * $DESTINATION_FOLDER/clean.sh"
        ) | crontab -

    fi
    # print done
    echo "done"
elif [ "$1" == "u" ]; then
    # uninstall
    echo "uninstalling..."
    # uninstall from crontab
    crontab -l | grep -v "clean.sh" | crontab -
    # remove the folder
    rm -rf $DESTINATION_FOLDER
else
    echo "invalid action, use i for install or u for uninstall"
fi
