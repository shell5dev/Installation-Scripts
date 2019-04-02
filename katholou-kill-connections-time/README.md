## Script request:
https://forum.shell5.dev/topic/7/kill-any-unwanted-ssh-connections-to-my-centos/7

## Content:
kill.sh - Script which kill all ssh sessions older than **30 minutes**

## Usage:

```bash
bash kill.sh
```

Optional: 

- Add cron job that will run this script every 5 minutes for example.
```bash
crontab -e
*/5 * * * * /bin/bash /home/$USER/kill.sh
```
This cron job assumes script is in home directory of user who's running the script. If it's not, adjust it accordingly.
