#!/bin/bash

# check if consul start
consul info || exit 1

interfaces=$(ls -1 /sys/class/net | grep -v "lo")

OLDIFS=$IFS
IFS=$'\n'
for iface in $interfaces
do
	NETWORK=$(sipcalc $iface | grep "Network address" | rev | cut -d' ' -f 1 | rev)
    MASK=$(sipcalc $iface | grep "Network mask (bits)" | rev | cut -d' ' -f 1 | rev)
    CDIR="$NETWORK/$MASK"
    consul_ips=$(nmap -PN -p 8301,8302 --open -oG - $CDIR | awk '$NF~/Up/{print $2}')
    for ip in $consul_ips
    do
        consul join $ip
    done
done
IFS=$OLDIF
