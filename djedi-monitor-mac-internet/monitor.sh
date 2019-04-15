#!/bin/bash -

#title           :monitor-mac-internet.sh
#description     :Monitor MAC addresses connected and internet availability.
#author	         :filips (filips@vaskir.co)
#date            :April 15th 2019
#version         :0.1
#usage	         :bash monitor.sh
#notes           :Be sure to setup cronjob that will run this script
#bash_version    :GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin18)


set -u

# VARS
IP_RANGE="X.X.X.X-XXX" # Choose lowest possible range on DHCP for faster scan time.
DEVICES_LIST=/tmp/devices.list
LOG_FILE="${LOG_FILE:=/tmp/scan.log}"
READ_LOG=$(cat /tmp/scan.log)
STATUSLOG=/tmp/STATUSLOG
URL=https://google.com
LOCKFILE="${LOCKFILE:=/tmp/scan_network.lock}"
EMPTRY_RESULT_THRESHOLD="${EMPTY_SCAN_THRESHOLD:=20}"
SLEEP_INTERVAL="${SLEEP_INTERVAL:=5}"
MAC_ADDRESESSES=$(while read -r line; do echo "$line";done < $DEVICES_LIST )
consecutive_empty_result_count=0
scan_result=''
last_post=''
net_result=''
net_last_result=''

post_to_slack() {
 curl -X POST --data-urlencode "payload={\"channel\": \"#CHANNELHERE\", \"username\": \"USERNAMEHERE\", \"text\": \"This is posted to #CHANNEL .\", \"icon_emoji\": \":ghost:\"}" https://hooks.slack.com/services/#THEHOOK
post_to_slack_internet() {
  curl -X POST --data-urlencode "payload={\"channel\": \"#CHANNELHERE\", \"username\": \"USERNAMEHERE\", \"text\": \"Internet was down,here is the log $READ_LOG .\", \"icon_emoji\": \":ghost:\"}" https://hooks.slack.com/services/#THEHOOK

}
#--------------------------------
printf "\n"

#List devices
printf "Checking for these mac addresses :
$MAC_ADDRESESSES"

printf "\n"
echo "________________________________________"
printf "\n"

#--------------------------------

# Check/list MAC addreses
check_devices(){
while read DEVICE_MAC; do
  if sudo nmap -sP $IP_RANGE | grep -q $DEVICE_MAC ; then
    log "Found $DEVICE_MAC"
    else
    log "Not found $DEVICE_MAC"
  fi
done < $DEVICES_LIST
}

# Function for time format
timestamp() {
  date '+%Y-%m-%d %H:%M:%S%z'
}

# Log function to imprint time
log() {
  echo "$(timestamp) :: $*" >> "$LOG_FILE"
}

# Scan

scan() {
    log "Starting scan of $IP_RANGE"
if sudo nmap -sn "$IP_RANGE" | grep -if $DEVICES_LIST >> "$LOG_FILE"; then
   scan_result='someone_home'
 else
   scan_result='no_one_home'
fi
   log "Got scan result [${scan_result}]"
}

# Scan network
scannetwork() {
    log "Starting scan for connecitivty to $URL"
    CHECK_CONNECTIVITY="$(wget -q --tries=1 --timeout=10 --spider $URL)"
    echo $?
if [[ $? -eq 0 ]]; then
    net_result='internet'
  else
    net_last_result='nointernet'
fi
    log "Got net result [${net_result}]"
}

# Post if state changed for NET
post_if_net_state_changed() {
if [[ "$net_result" != "$net_last_result" ]]; then
    log "Posting net result [${net_result}] to notify because it was different than the last posted result: [${net_last_result}]"
post_to_slack_internet
  else
    log "Skipping notify because scan result [${net_result}] was the same as our last post [${net_last_result}]"
fi
  net_last_result=$net_result
}

# NET handler

handle_net_result() {
if [[ "$net_result" == "internet" ]]; then
    log "Got a [${net_result}], resetting consecutive empty result count to 0"
    consecutive_empty_result_count=0
    post_if_net_state_changed
  elif [[ "$net_result" == "nointernet" ]]; then
    ((consecutive_empty_result_count++))
    if [[ "$consecutive_empty_result_count" -gt "$EMPTRY_RESULT_THRESHOLD" ]]; then
      post_if_net_state_changed
    elif
       log "Consecutive empty result count [${consecutive_empty_result_count}] <= threshold [${EMPTRY_RESULT_THRESHOLD}], skipping notify"
       [[ "$consecutive_empty_result_count" -lt "$EMPTRY_RESULT_THRESHOLD" ]]; then
         post_if_net_state_changed
    fi
fi

}

# Post if MAC state changed

post_if_state_changed() {
  if [[ "$scan_result" != "$last_post" ]]; then
    log "Posting scan result [${scan_result}] to notify because it was different than the last posted result: [${last_post}]"
post_to_slack
check_devices
  else
    log "Skipping notify because scan result [${scan_result}] was the same as our last post [${last_post}]"
  fi
  last_post=$scan_result
}

# Handle MAC results

handle_scan_result() {
  if [[ "$scan_result" == "someone_home" ]]; then
    log "Got a [${scan_result}], resetting consecutive empty result count to 0"
    consecutive_empty_result_count=0
    post_if_state_changed
  elif [[ "$scan_result" == "no_one_home" ]]; then
    ((consecutive_empty_result_count++))
    if [[ "$consecutive_empty_result_count" -gt "$EMPTRY_RESULT_THRESHOLD" ]]; then
      post_if_state_changed
    elif
       log "Consecutive empty result count [${consecutive_empty_result_count}] <= threshold [${EMPTRY_RESULT_THRESHOLD}], skipping notify"
       [[ "$consecutive_empty_result_count" -lt "$EMPTRY_RESULT_THRESHOLD" ]]; then
         post_if_state_changed
    fi
  fi

}

# Forever run loop

scan_forever() {
  while :; do
    scan
    scannetwork
    handle_scan_result
    handle_net_result
    sleep $SLEEP_INTERVAL
  done
}

# Check for dependencies

check_dependencies() {
  command -v nmap &>/dev/null || { echo "nmap is required but not installed !"; exit 1; }
  command -v flock &>/dev/null || { echo "flock is required but not installed !"; exit 1; }
  command -v curl &>/dev/null || { echo "curl is required but not installed, !"; exit 1; }
  command -v wget &>/dev/null || { echo "wget is required but not installed, !"; exit 1; }

 }

# Main function to prevent multi script spawn/run

main() {
   [[ $(id -u) -eq 0 ]] || { echo "Script must be run as root !"; log "Script must be run as root!"; exit 1; }

   exec 200>"$LOCKFILE"
   if ! flock -n 200  ; then
      echo "another instance of the script is running";
      exit 0
   fi

   check_dependencies
   scan_forever
   }

main
