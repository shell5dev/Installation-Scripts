#!/bin/bash -       
#title           :install.sh
#description     :Docker install and dockerizing simple java based web server
#author	         :ajvn (ivans@vaskir.co)
#date            :April 2nd 2019
#version         :0.1    
#usage	         :bash install.sh
#notes           :This one uses OpenJDK for Java app
#bash_version    :GNU bash, version 4.4.23(1)-release (x86_64-redhat-linux-gnu)
#==============================================================================

# This part checks if your user is part of sudoers file, and if passwordless sudo has been enabled.
echo "========================================="
echo "Sudo is needed to install and use docker!" 
echo "========================================="
sleep 1;
echo ""

function checkSudo(){
    echo "Checking if user is passwordless sudo..."
    TEST="$(sudo -n /bin/cat /var/log/syslog > /dev/null; echo $?)"
    if [[ $TEST -eq 0 ]]; then
        echo "Passwordless sudo for this user is enabled or password has been entered recently."
    else
        CHECK_SUDO=$(sudo -v; echo $?)    
        if [[ $CHECK_SUDO -eq 0 ]]; then
            echo "Password is correct."
        else 
            echo "Wrong password or user is not part of sudoers!"
            exit 1
        fi    
    fi
}

checkSudo

echo ""

echo "Checking if docker, git and maven are installed..."
sleep 1
# Check if docker is installed
function checkDeps(){
    LIST_DOCKER="$(dpkg -l | grep docker | echo $?)"
    LIST_GIT="$(dpkg -l | grep git | echo $?)"
    LIST_MAVEN="$(dpkg -l | grep mvn | echo $?)"
    if ! [[ $LIST_DOCKER -eq 0 ]]; then
        echo "Docker is installed." 
    else
        echo "Docker is not installed, installing now..."
        sudo apt update
        sudo apt-get install \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common -y
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable"
        sudo apt update
        sudo apt-get install docker-ce docker-ce-cli containerd.io -y
        sleep 1
        echo "Docker has been installed successfully!"
    fi
    if ! [[ $LIST_GIT -eq 0 ]]
        echo ""
        echo "Git is installed."    
    else 
        echo ""
        echo "Git is not installed, installing now..."
        sudo apt install git -y
    fi
    if ! [[ $LIST_MAVEN -eq 0 ]]
        echo ""
        echo "Maven is installed."
    else    
        echo ""
        echo "Maven is not installed, installing now..."
        wget -P /tmp http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
        sudo mkdir -p /opt/maven
        tar xf /tmp/apache-maven-3.3.9-bin.tar.gz -C /opt
        echo "Maven is installed."
    fi
}

checkDeps

echo ""
echo "Checking if docker is running..."
CHECK_DOCKER="$(systemctl status docker >/dev/null; echo $?)"
if [[ $CHECK_DOCKER -eq 0 ]]; then  
    echo "Docker is running."
else
    echo "Looks like docker is not running. Starting docker, and enabling it on startup..."
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Dockerizing simple java web server (https://github.com/dasanjos/java-WebServer)
echo ""
echo "Cloning git repo, building .jar, and creating container..."
mkdir -p test-java-app
cd test-java-app
git clone https://github.com/dasanjos/java-WebServer.git
cd java-WebServer
mvn clean package
cp target/java-WebServer-0.1-jar-with-dependencies.jar ../
cd ../
echo "Building docker image..."
sudo docker build -t simple-java-image .
sudo docker run --name simple-java-server --publish 55555:55555 --restart always -d -t simple-java-image


echo ""
echo "Done. You can check server on http://127.0.0.1:55555"
