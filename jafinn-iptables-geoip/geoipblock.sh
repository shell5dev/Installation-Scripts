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
apt-get install iptables-dev xtables-addons-common libtext-csv-xs-perl pkg-config iptables-persistent -y

# Installing needed PERL Module
cpan -i Net::CIDR::Lite

# Download XTables
echo ""
echo "Downloading xtables ..."
XTABLES_URL="https://downloads.sourceforge.net/project/xtables-addons/Xtables-addons/xtables-addons-3.3.tar.xz"

wget -P /tmp $XTABLES_URL

cd /tmp
tar xf xtables-addons-3.3.tar.xz -C $HOME/
cd $HOME/xtables-addons-3.3

# Compiling addon
echo "Compiling xtables..."
echo ""
sleep 1
./configure
make 
make install

echo "Installing GeoIP Database..."
echo ""
mkdir -p /usr/share/xt_geoip/LE
cd $HOME/xtables-addons-3.3/geoip
./xt_geoip_dl
./xt_geoip_build -S GeoLite2-Country-* -D /usr/share/xt_geoip/LE

echo "Setting up Iptables rules..."
iptables -P INPUT ACCEPT
while read in;
do iptables -I INPUT -m geoip --src-cc $in -p tcp -m tcp -m multiport --dports 80,443 -j DROP;
done < /$HOME/countries.txt

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