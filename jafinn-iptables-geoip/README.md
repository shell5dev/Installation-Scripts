## Script request:
https://forum.shell5.dev/topic/8/drop-reject-all-packets-from-region/

## Description:
Utilize iptables's xtables module to geoip block requests on 80/443 ports.

Optimized for Debian 9.

## Content:
geoipblock.sh - Script installs needed dependencies, builds xtables 3.3 from the source, blocks IPs originating from countries in countries.txt file, and optionaly saves iptables rules utilizing netfilter-persistent package. 

countries.txt - Contains list of country codes of countries located in Asia. 

Notes: If netfilter-persistent package is not already installed on the machine, it will prompt if you wish to save existent rules during install. Answer no.

There will also be prompt by cpan perl module about automatic setup, you should respond with yes. 

## Usage:
```bash
sudo bash geoipblock.sh
```

## Credits:
Xtables: http://xtables-addons.sourceforge.net/