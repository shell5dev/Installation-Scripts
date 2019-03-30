#!/bin/bash -       
#title           :install.sh
#description     :Automatic deploy of MariaDB Galera in docker swarm
#author		 :ajvn (ivans@vaskir.co)
#date            :March 30th 2019
#version         :0.1    
#usage		 :bash install.sh
#notes           :Enjoy
#bash_version    :GNU bash, version 4.4.23(1)-release (x86_64-redhat-linux-gnu)
#==============================================================================

# This part checks if your user is part of sudoers file, and if passwordless sudo has been enabled. 
echo "====================================="
echo "Sudo is needed to deploy docker swarm" 
echo "====================================="
sleep 1;
echo ""

echo "Checking if docker is running..."
CHECK_DOCKER="$(systemctl status docker >/dev/null; echo $?)"
if [[ $CHECK_DOCKER -eq 0 ]]; then  
    echo "Docker is running."
else
    echo "Looks like docker is not running."
    exit
fi

echo ""

function checkSudo(){
    echo "Checking if user is passwordless sudo..."
    TEST="$(sudo -n /usr/bin/docker ps > /dev/null; echo $?)"
    if [[ $TEST -eq 0 ]]; then
        echo "Passwordless sudo for this user is enabled or password has been entered recently."
    else
        CHECK_SUDO=$(sudo -v; echo $?)    
        if [[ $CHECK_SUDO -eq 0 ]]; then
            echo "Password is correct."
        else 
            echo "Wrong password or user is not part of sudoers!"
            exit
        fi    
    fi
}

checkSudo
echo ""

# Creating secrets
echo "Creating secrets..."
mkdir -p .secrets
openssl rand -base64 25 > .secrets/xtrabackup_password
openssl rand -base64 25 > .secrets/mysql_password
openssl rand -base64 25 > .secrets/mysql_root_password
echo "Secrets created."

echo ""

# Initializing docker swarm
echo "Do you want to initialize docker swarm (necessary if you don't have swarm already) y/n?: "
read answer
if [[ $answer =~ ^[Yy]$ ]]; then
    echo "Initializing docker swarm..."
    sudo docker swarm init
elif [[ $answer =~ ^[Nn]$ ]]; then
    echo "Not initialzing docker swarm."
else
    echo "Please type y or n."
    exit
fi

echo ""
# Deploying galera stack in docker swarm
echo "Deploying stack..."
CHECK_STACK="$(sudo docker stack deploy -c docker-compose.yml galera >/dev/null; echo $?)"
if [[ $CHECK_STACK -eq 0 ]]; then
    echo "Stack deployed"
else    
    exit
fi

echo ""

# Retriving healthy status
while ! [ $(sudo -n /usr/bin/docker ps -a | grep 'healthy' > /dev/null; echo $?) -eq 0 ]
do 
    echo "Not ready yet. Sleeping for 10 seconds"
    sleep 10
done

echo ""

# After these 2 are clustered, we need to remove seed container and after that you'll be able to scale more
echo "Scaling nodes..."
sudo docker service scale galera_node=2

echo ""
echo "Checking health status..."
while ! [ $(sudo -n /usr/bin/docker ps -a | grep 'healthy' > /dev/null; echo $?) -eq 0 ]
do 
    "Not ready yet. Sleeping for 10 seconds"
    sleep 10
done

echo ""
# Remove seed container
echo "Removing seed container..."
sudo docker service scale galera_seed=0

echo "There are currently 2 nodes running. Would you like to scale more? y/n: "

echo "Do you want to initialize docker swarm (necessary if you don't have swarm already) y/n?: "
read answer2
if [[ $answer2 =~ ^[Yy]$ ]]; then
    echo "How many nodes do you want?: "
    read containerNumber
    if [ $containerNumber -eq $containerNumber 2>/dev/null ]
    then
        sudo docker service scale galera_node=$containerNumber
    else    
        echo "Please provide a number!"
    fi

elif [[ $answer2 =~ ^[Nn]$ ]]; then
    echo "Done. Enjoy!"
else
    echo "Please type y or n."
    exit
fi