#!/bin/bash -       
#title           :geoipblock.sh
#description     :Drops incoming traffic from Asia
#author	         :ajvn (ivans@vaskir.co)
#date            :April 5th 2019
#version         :0.1    
#usage	         :sudo bash geoipblock.sh
#notes           :Requires root privileges
#bash_version    :GNU bash, version 4.4.23(1)-release (x86_64-redhat-linux-gnu)
#==============================================================================

# Copy countries.txt to home path
echo "Copying countries list to home directory..."
echo ""
cp countries.txt $HOME/

# Install packages required for xtables
echo "Installing dependencies..."
sleep 1
apt-get update
apt-get install iptables-dev iptables-persistent -y

# Set PATH
ISO="$(cat $HOME/countries.txt)" 
IPT=/sbin/iptables
WGET=/usr/bin/wget
EGREP=/bin/egrep 

# Do not edit below
SPAMLIST="countrylist"
ZONEROOT="/root/iptables"
DLROOT="http://www.ipdeny.com/ipblocks/data/countries" 

cleanOldRules(){
$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X
$IPT -P INPUT ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -P FORWARD ACCEPT
} 
# Create directory to store zone files 
[ ! -d $ZONEROOT ] && /bin/mkdir -p $ZONEROOT 

# Clear iptables rules
cleanOldRules 

# Create a new iptables list
$IPT -N $SPAMLIST

for c in $ISO
do
    # Local zone file
    tDB=$ZONEROOT/$c.zone # Get fresh zone file
    $WGET -O $tDB $DLROOT/$c.zone # Country specific log message
    SPAMDROPMSG="$c Country Drop" # Get
    BADIPS=$(egrep -v "^#|^$" $tDB)
    for ipblock in $BADIPS
    do
        $IPT -A $SPAMLIST -s $ipblock -j LOG --log-prefix "$SPAMDROPMSG"
        $IPT -A $SPAMLIST -s $ipblock -j DROP
    done
done 

# Drop everything
$IPT -I INPUT -j $SPAMLIST
$IPT -I OUTPUT -j $SPAMLIST
$IPT -I FORWARD -j $SPAMLIST 

echo ""
echo "Iptables rules are applied..."
sleep 1

echo ""
echo "Do you wish to save iptables rules on next reboot? y/n:  "
read answer
if [[ $answer =~ ^[Yy]$ ]]; then
    echo ""
    echo "Setting up persistent rules..."
    service netfilter-persistent save    
elif [[ $answer =~ ^[Nn]$ ]]; then
    echo "Ip tables rules will be lost after next reboot"
    exit 0
else
    echo "Please type y or n."
    exit 1
fi