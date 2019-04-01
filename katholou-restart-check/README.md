## Script request:
https://forum.shell5.dev/topic/5/script-will-check-if-the-server-restarted

## Content:

check.sh - Script checks if server has been restarted in last 5 minutes and sends log file to a different server.

## Usage:

1. SERVER_IP= # Enter IP address from central server

SERVER_USER="" # Enter user for SSH login

SERVER_SSH="" # Enter path to ssh key

SERVER_SSH_PORT= # Enter ssh port number

2. After you enter these parameters in script itself run it with:

```bash
bash check.sh
```
3. Add cron job that will run this script every 5 minutes.
```bash
crontab -e
*/5 * * * * /bin/bash /home/$USER/check.sh >> /tmp/check_script.log
```
This cron job assumes script is in home directory of user who's running the script. If it's not, adjust it accordingly.
