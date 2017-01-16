#!/bin/bash
# If you want this script to run regularly, put it in cron.
# This script uses Stopforum downloads http://www.stopforumspam.com/downloads/

#Choose the number of days your would like to download, choices are 1,30,90,180,365
DAYS="90"

# path to iptables
IPTABLES="/sbin/iptables";

# list of known spammers
URL="www.stopforumspam.com/downloads/listed_ip_${DAYS}.zip";

# save local copy here
FILE="/tmp/listed_ip_${DAYS}.zip";
FILE_UNZIPPED="/tmp/listed_ip_${DAYS}.txt";

# iptables custom chain
SET="Stopforumspam";

wget -qc $URL -O $FILE
if ! [ -s $FILE ];then
        echo "The source file $FILE could not be downloaded, it might have been downloaded to many times (max 2 per day)"
        unlink $FILE
        exit 1
fi

#Reload iptables since we need to update it
service iptables reload

# get a copy of the spam list
unzip $FILE -d /tmp/  > /dev/null 2>&1 #No output required, messes up cron mail

ipset destroy $SET 2 > /dev/null
ipset create $SET hash:ip maxelem 600000
# iterate through all known spamming hosts
for IP in $( cat $FILE_UNZIPPED | egrep -v '^;' | awk '{ print $1}' ); do

    # add the ip address to the chain
    ipset add $SET $IP

    #echo $IP

done
#Add the list with one iptables line
$IPTABLES -I INPUT -m set --match-set $SET src -j DROP

OUTPUT="$(ipset -L $SET|wc -l)"
echo "Downloaded $DAYS days list and added ${OUTPUT} spammers to iptables in one rule"

# Remove the spam list
unlink $FILE
unlink $FILE_UNZIPPED
