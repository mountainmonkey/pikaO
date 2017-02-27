###############################################################################
# pikaO
# RHEL/CentOS 6 Edition
# Version 1.3
# Mon Feb 27 10:57:33 PST 2017
# Felix Wu
# pika"O" is a poor man's monitoring script, it checks basic CPU, RAM and 
# root partition usage.
# When this is run by a cron job, it continue to send spam emails until it goes
# under the threshold. 
# O represents pika open its mouth making a warning call on constant intervals. 
###############################################################################

#!/bin/bash

THCPUUSED=50
THDISKUSED=80
THMEMFREE=20

MAILTO=spamme@talusfield.home
MAILFROM=pika.dontcallme@`hostname`
SMTP=''

# disk
DISK=`df / | grep "% /" | awk '{ print $(NF-1)}' | sed 's/%//g'`

#cpu
CPU=`vmstat 1 2 -a | tail -1 | awk '{print $13+$14}'`

# mem
MEM=`free | grep "\-\/\+" | awk '{ printf ("%.0f\n",($4/($3+$4))*100) }'`
#MEM=`free | grep Mem | awk '{ printf ("%.0f\n",($4/$2)*100) }'`

function sysstat() {
    printf "CPU: %s%% used\n" "$CPU"
    printf "Memory: %s%% free\n" "$MEM"
    printf "root partition: %s%% used\n" "$DISK"
    vmstat 1 2 -a
    echo "--------------------------------------------------------------------------------"
    df -h /
    echo "--------------------------------------------------------------------------------"
    free -m
    echo "--------------------------------------------------------------------------------"
    eval $1
    echo "--------------------------------------------------------------------------------"
}

if [ "$1" = "-v" ] ; then
    printf "[pikaO] is running in verbose mode...\n"
    sysstat "top -b -n 1 -a" | head -30
    exit 1;
fi

if [ "$1" = "-t" ] ; then
    printf "[pikaO] is running in test mode to send an alert email...\n"
    SYSSTAT=`sysstat "top -b -n 1 -a"`
    printf "Sorry to annoy you, this is a testing alert, please ignore it!\n%s" "$SYSSTAT" | mailx -r $MAILFROM -s `hostname -s`"/"`hostname -i`": TEST ALERT" $SMTP $MAILTO
    exit 1;
fi

if [ "$CPU" -ge "$THCPUUSED" ] ; then
    SYSSTAT=`sysstat "top -b -n 1"`
    printf "%s" "$SYSSTAT" | mailx -r $MAILFROM -s `hostname -s`"/"`hostname -i`": cpu high "$CPU"%" $SMTP $MAILTO
fi

if [ "$DISK" -ge "$THDISKUSED" ] ; then
    SYSSTAT=`sysstat "top -b -n 1 -a"`
    printf "%s" "$SYSSTAT" | mailx -r $MAILFROM -s `hostname -s`"/"`hostname -i`": root partition low "$DISK"%" $SMTP $MAILTO
fi

if [ "$MEM" -le "$THMEMFREE" ] ; then
    SYSSTAT=`sysstat "top -b -n 1 -a"`
    printf "%s" "$SYSSTAT" | mailx -r $MAILFROM -s `hostname -s`"/"`hostname -i`": memory low "$MEM"%" $SMTP $MAILTO
fi
