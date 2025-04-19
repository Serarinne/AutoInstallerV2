#!/bin/bash
clear
data=(`find /var/log/ -name '*.log'`);
for log in "${data[@]}"
do
echo > $log
done
data=(`find /var/log/ -name '*.err'`);
for log in "${data[@]}"
do
echo > $log
done
echo > /var/log/syslog
echo > /var/log/btmp
echo > /var/log/messages
echo > /var/log/debug