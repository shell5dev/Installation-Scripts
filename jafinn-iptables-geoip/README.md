## Script request:
https://forum.shell5.dev/topic/8/drop-reject-all-packets-from-region/

## Description:
Blocks all incoming traffic from Asia.

## Content:
geoipblock.sh - Script installs needed dependencies, blocks IPs originating from countries in countries.txt file, and optionaly saves iptables rules utilizing netfilter-persistent package. 

countries.txt - Contains list of country codes of countries located in Asia. 

Notes: If netfilter-persistent package is not already installed on the machine, it will prompt if you wish to save existent rules during install. 

## Usage:
```bash
sudo bash geoipblock.sh
```

## Credits:
Cyberciti - https://www.cyberciti.biz/faq/block-entier-country-using-iptables/