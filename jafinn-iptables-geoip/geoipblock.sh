#!/bin/bash -       
#title           :geoipblock.sh
#description     :Utilize iptables module xtables to geoip block certain countries on port 80/443 
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


ISO="$(cat $HOME/countries.txt)" ### Set PATH ###
IPT=/sbin/iptables
WGET=/usr/bin/wget
EGREP=/bin/egrep ### No editing below ###
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
# create a dir
[ ! -d $ZONEROOT ] && /bin/mkdir -p $ZONEROOT 

# clean old rules
cleanOldRules # create a new iptables list
$IPT -N $SPAMLIST

for c in $ISO
do
    # local zone file
    tDB=$ZONEROOT/$c.zone # get fresh zone file
    $WGET -O $tDB $DLROOT/$c.zone # country specific log message
    SPAMDROPMSG="$c Country Drop" # get
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
iptables -S

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