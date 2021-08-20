#!/bin/bash

#configure the target`s ip segment in three octs
ip=192.168.0

min=0
max=20

for (( oct=$min; oct <= max; oct++)) ; do
	if ping -c1 -W 1 "$1.$oct" &> /dev/null
		then echo "$1.$oct is up"; echo "$ip.$oct" >> targets.txt 
		else echo "$1.$oct is down"
	fi
done