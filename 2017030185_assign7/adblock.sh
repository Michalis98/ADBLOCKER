#!/bin/bash
# You are NOT allowed to change the files' names!
domainNames="domainNames.txt"
IPAddresses="IPAddresses.txt"
adblockRules="adblockRules"

function adBlock() {
    if [ "$EUID" -ne 0 ];then
        printf "Please run as root.\n"
        exit 1
    fi
    if [ "$1" = "-domains"  ]; then
        while read ip; do
 	 hostname=`host $ip| awk '/has address/ { print $4  }'`
  	if [ ! -z "$hostname" ]; then
   	 echo "$hostname" >> IPAddresses.txt
   	 echo $hostname
 	 fi
	done < domainNames.txt

	while read ip; do
	  iptables -A INPUT -s $ip -j REJECT
	  iptables -A OUTPUT -d $ip -j REJECT
	done < IPAddresses.txt
        true
            
    elif [ "$1" = "-ips"  ]; then
        while read ip; do
  	iptables -A INPUT -s $ip -j REJECT
  	iptables -A OUTPUT -d $ip -j REJECT
	done < IPAddresses.txt

        true
        
    elif [ "$1" = "-save"  ]; then
        
        iptables-save > adblockRules
        
        true
        
    elif [ "$1" = "-load"  ]; then
        iptables-restore < adblockRules
        true

        
    elif [ "$1" = "-reset"  ]; then
        iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -t nat -F
	iptables -t mangle -F
	iptables -F
	iptables -X
        true

        
    elif [ "$1" = "-list"  ]; then
       iptables -S
        true
        
    elif [ "$1" = "-help"  ]; then
        printf "This script is responsible for creating a simple adblock mechanism. It rejects connections from specific domain names or IP addresses using iptables.\n\n"
        printf "Usage: $0  [OPTION]\n\n"
        printf "Options:\n\n"
        printf "  -domains\t  Configure adblock rules based on the domain names of '$domainNames' file.\n"
        printf "  -ips\t\t  Configure adblock rules based on the IP addresses of '$IPAddresses' file.\n"
        printf "  -save\t\t  Save rules to '$adblockRules' file.\n"
        printf "  -load\t\t  Load rules from '$adblockRules' file.\n"
        printf "  -list\t\t  List current rules.\n"
        printf "  -reset\t  Reset rules to default settings (i.e. accept all).\n"
        printf "  -help\t\t  Display this help and exit.\n"
        exit 0
    else
        printf "Wrong argument. Exiting...\n"
        exit 1
    fi
}

adBlock $1
exit 0
