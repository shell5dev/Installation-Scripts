## Script request:
https://forum.shell5.dev/topic/6/automount-encrypted-file-in-linun-mint-v-18-03/

## Content:
install.sh - Script installs Docker, Git, Maven, and it builds docker container based on provided Dockerfile.

Dockerfile - Utilize OpenJDK 8 to package Java application.

## Usage:

Clone this repository, navigate to katholou-dockerize-app, and run install.sh
```
git clone https://git.shell5.dev/shell5dev/installation-scripts.git
cd installation-scripts/katholou-dockerize-app/
bash install.sh
```

Note:

If you notice any strange issues that are connected to old Docker version, be sure to remove all docker packages and remove any third-party repository that might host those old docker packages.
## Credits:

Simple java web server: https://github.com/dasanjos/java-WebServer