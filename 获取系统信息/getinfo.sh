#!/bin/bash

cat /proc/cpuinfo | awk '/^processor/ {s++} END{print "cpu num: "s}'
free -m | awk '/^Mem/ {print "memory total: " ($2/1024.0)"G"}'
free -m | awk '/^Mem/ {print "memory free: "$4"M"}'
df -hT | awk '{if($7~/\/$/){print "disk size: "$3}}'
echo system bit: $(getconf LONG_BIT)
ps aux | awk '{if($8~/R/){++s}} END {print  "process: "s}'
echo software num: $(dpkg -l | wc -l)
ip a s eth0 | awk '{if($1~/inet$/){split($2,s,"/");print "ip: " s[1]}}'