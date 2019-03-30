## Content:

install.sh - Script used for deploying MariaDB Cluster in Swarm

remove.sh - Script used for leaving (and removing) swamp cluster, removing unused images, containers and networks by utizing docker's prune command, and removing ALL Docker volumes on the system. Be very careful with this script, and use it only if this is only Docker project you're running on machine where you want to run this script.

docker-compose.yml - This file utilize great work of [colinmollenhour](https://hub.docker.com/u/colinmollenhour). It's used to deploy MariaDB cluster in Docker Swarm.

## Credits:
https://hub.docker.com/u/colinmollenhour
https://hub.docker.com/r/colinmollenhour/mariadb-galera-swarm
https://github.com/colinmollenhour/mariadb-galera-swarm/tree/master/examples/swarm