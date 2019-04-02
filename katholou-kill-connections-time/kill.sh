#!/bin/bash

# Session timeout in minutes:
session_minimum_timeout=30

# Convert session time to seconds
let session_timeout_seconds=session_minimum_timeout*60

# Create an array with the active sessions details
declare -a session_array="$(ps -eo etimes,pid,cmd --sort=etimes | grep '@pts' | grep -v 'grep\|root'| awk -F 'sshd:' '{ print $1 }')"

# Iterate through each line of the array
printf '%s\n' "${session_array[*]}" | while read line; do

    session_time="$(echo $line | awk '{print $1}')"
    session_pid="$(echo $line | awk '{print $2}')"

    # If the timeout value we set is less or equal to the session duration, kill the PID
    (( $session_time>=$session_timeout_seconds )) && kill -9 $session_pid

done
