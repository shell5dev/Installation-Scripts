## Script request:

https://forum.shell5.dev/topic/13/remote-live-backing-up-custom-game-server-with-sqlite3-databases/5

## Content:

backup.sh - Script used for backing up sqlite3 database and game server files

## Requirements:

Installed packages:

- zip
- rsync
- mailx

Obtain them by running:

Debian based OS(Ubuntu or similar) `apt-get install zip rsync mailx`

RHEL based OS (CentOS or similar) `yum install zip rsync mailx`


### Variables to adjust within script:

```
#PATHS
dbpath=/path/to/game.db # Path to your .db file
backup_location=/path/to/backup/directory # Location of where backup will be stored
server_files=/path/to/game_server_files # Location of game server files
backup_server="user@example.com:/backup/location" #Server where to send the backups

#MAIL
smtp_server=smtps://smtp.example.com:465  # SMTP server >>> notice the smtp(S) and port number, (S) stands for encrytion.
user_pass='user@example.com:12345678' # Username and password in format user:password
from=user@example.com # From parameter (from which email address are you sending)
to=myemail@example.com # To parameter (to who you are sending)
backup_status=/tmp/status.txt #Temporal status of backup message
```
