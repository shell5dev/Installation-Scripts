#!/bin/bash -       
#title           :backup.sh
#description     :Backup sqlite db and game files
#author		 :filips (filips@vaskir.co)
#date            :Nov. 7th 2019
#version         :0.1    
#usage		 :bash backup.sh
#notes           :Enjoy
#bash_version    :GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin19)
#website         :https://shell5.dev
#==============================================================================


#PATHS
dbpath=/path/to/all/db # Path to your .sqlite files
backup_location=/path/to/backup/directory # Location of where backup will be stored
server_files=/path/to/game_server_files # Location of game server files
backup_server="user@example.com:/backup/location" #Server where to send the backups

#MAIL
smtp_server=smtps://smtp.example.com:465  # SMTP server >>> notice the smtp(S) and port number, (S) stands for encrytion.
user_pass='user@example.com:12345678' # Username and password in format user:password
from=user@example.com # From parameter (from which email address are you sending)
to=myemail@example.com # To parameter (to who you are sending)
backup_status=/tmp/status.txt #Temporal status of backup message



#Check requirements
## zip 
if ! [ -x "$(command -v zip)" ]; then
  echo 'Error: zip is not installed.' >&2
  exit 1
fi
## rsync
if ! [ -x "$(command -v rsync)" ]; then
  echo 'Error: rsync is not installed.' >&2
  exit 1
fi
## mailx
if ! [ -x "$(command -v mailx)" ]; then
  echo 'Error: mailx is not installed.' >&2
  exit 1
fi

#Make multiple DB Backup
for dbname in "$dpath"/*.sqlite
do
sqlite3 $dbpath ".backup '$backup_location/backup."$dbname".$(date +"%d-%m-%y").sqlite'"
done

# Make files backup
zip -r $backup_location/serverfiles.(date +"%d-%m-%y").zip $server_files/*

# Send backups to the server
rsync -r -z -c $backup_location/* $backup_server
if [ "$?" -eq "0" ]
then
  rm -rf $backup_location/backup.$(date +"%d-%m-%y").sqlite  #Delete DB for current day
  rm -rf $backup_location/serverfiles.(date +"%d-%m-%y").zip #Delete files for current day
  echo "Done"
  echo "Subject: Success" > $backup_status
else
  echo "Error while transfering"
  echo "Subject: Error while transfering" > $backup_status
curl --url "$smtp_server" --ssl-reqd \
  --mail-from "$from" --mail-rcpt "$to" \
  --upload-file $backup_status --user $user_pass
fi
