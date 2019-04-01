#!/bin/bash -       
#title           :check.sh
#description     :Check if server restarted and sending notification to a different server
#author	         :ajvn (ivans@vaskir.co)
#date            :March 30th 2019
#version         :0.1    
#usage	         :bash check.sh
#notes           :Be sure to setup cronjob that will run this script
#bash_version    :GNU bash, version 4.4.23(1)-release (x86_64-redhat-linux-gnu)
#==============================================================================

SERVER_IP= # Enter IP address from central server
SERVER_USER="" # Enter user for SSH login
SERVER_SSH="" # Enter path to ssh key
SERVER_SSH_PORT= # Enter ssh port number

# Check for how long server has been running, and if restarted in last 5 minutes
CH_UPTIME=$(uptime | awk '{print $3}' | sed s'/[:,]//g')

# Check when last reboot happened
LAST_REBOOT="$(last -x | grep reboot | head -1 >> /home/$USER/last_reboot.log)"

if [ $CH_UPTIME -gt '6' ]; then
    echo "Server has not been restarted in at least 5 minutes."
    exit 0
else
    echo "Server has been restarted less than 5 minutes ago."
    scp -i $SERVER_SSH -P $SERVER_SSH_PORT /home/$USER/last_reboot.log $SERVER_USER@$SERVER_IP:~/ 
fi