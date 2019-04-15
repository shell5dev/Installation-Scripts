## Script request:

https://forum.shell5.dev/topic/10/script-to-check-mac-addresses-connected-disconnected-and-connectivity-via-e-mail

## Content:

monitor.sh - Script checks if MAC address is connected/disconnected, in case internet is down, it will forward logs via Slack when internet is restored.

## Usage:

Edit script to reflect desired values.

Populate the devices.list file with UPPER CASE MAC addresses - for example 1A:2B:3C:4D:5E:6F

**IP_RANGE="X.X.X.X-XXX"** # Enter IP range to process scan with nmap

**SLEEP_INTERVAL="${SLEEP_INTERVAL:=5}"** # Sleep interval in Seconds (Increase this size to number of seconds that you want the script to run)


Edit Slack/Mattermost or similar hooks for notificaiton, here is example for Slack
```text
post_to_slack() {
 curl -X POST --data-urlencode "payload={\"channel\": \"#CHANNELHERE\", \"username\": \"USERNAMEHERE\", \"text\": \"This is posted to #CHANNEL .\", \"icon_emoji\": \":ghost:\"}" https://hooks.slack.com/services/#THEHOOK
post_to_slack_internet() {
  curl -X POST --data-urlencode "payload={\"channel\": \"#CHANNELHERE\", \"username\": \"USERNAMEHERE\", \"text\": \"Internet was down,here is the log $READ_LOG .\", \"icon_emoji\": \":ghost:\"}" https://hooks.slack.com/services/#THEHOOK
```

### Optional parameters
```text
DEVICES_LIST=/tmp/devices.list
LOG_FILE="${LOG_FILE:=/tmp/scan.log}"
READ_LOG=$(cat /tmp/scan.log)
STATUSLOG=/tmp/STATUSLOG
URL=https://google.com
LOCKFILE="${LOCKFILE:=/tmp/scan_network.lock}"
EMPTRY_RESULT_THRESHOLD="${EMPTY_SCAN_THRESHOLD:=20}"
```

2. After you enter these parameters in script itself run it with:

```bash
bash monitor.sh
```
3. Add cron job that will run this script every 5 minutes.
```bash
crontab -e
*/5 * * * * /bin/bash /home/$USER/monitor.sh &
```
This cron job assumes script is in home directory of user who's running the script. If it's not, adjust it accordingly.
There is a mechanism which prevent the script to be spawned multiple times, a cronjob just ensures that the script is running.
