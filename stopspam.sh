#!/bin/bash
# If you want this script to run  regularly, put it in cron.
# This script uses Stopforum downloads http://www.stopforumspam.com/downloads/

# path to iptables
IPTABLES="/sbin/iptables";

# list of known spammers
URL="www.stopforumspam.com/downloads/listed_ip_90.zip";

# save local copy here
FILE="/tmp/listed_ip_90.zip";
FILE_UNZIPPED="/tmp/listed_ip_90.txt";

# iptables custom chain
SET="Stopforumspam";

wget -qc $URL -O $FILE
if ! [ -s $FILE ];then
        echo "The source file $FILE could not be downloaded, it might have been downloaded to many times (max 2 per day)"
        exit 1
fi

#Reload iptables since we need to update it
systemctl reload iptables

# get a copy of the spam list
unzip $FILE -d /tmp/

ipset create $SET hash:ip maxelem 200000
# iterate through all known spamming hosts
for IP in $( cat $FILE_UNZIPPED | egrep -v '^;' | awk '{ print $1}' ); do

    # add the ip address to the chain
    ipset add $SET $IP

    #echo $IP

done
#Add the list with one iptables line
$IPTABLES -I INPUT -m set --match-set $SET src -j DROP


echo "Done!"

# remove the spam list
#unlink $FILE
unlink $FILE_UNZIPPED

[root@webserver2 cron.daily]# vi stopspam.sh
[root@webserver2 cron.daily]# cat stopspam.sh
#!/bin/bash
# If you want this script to run  regularly, put it in cron.
# This script uses Stopforum downloads http://www.stopforumspam.com/downloads/

# path to iptables
IPTABLES="/sbin/iptables";

# list of known spammers
URL="www.stopforumspam.com/downloads/listed_ip_90.zip";

# save local copy here
FILE="/tmp/listed_ip_90.zip";
FILE_UNZIPPED="/tmp/listed_ip_90.txt";

# iptables custom chain
SET="Stopforumspam";

wget -qc $URL -O $FILE
if ! [ -s $FILE ];then
        echo "The source file $FILE could not be downloaded, it might have been downloaded to many times (max 2 per day)"
        exit 1
fi

#Reload iptables since we need to update it
systemctl reload iptables

# get a copy of the spam list
unzip $FILE -d /tmp/

ipset create $SET hash:ip maxelem 200000
# iterate through all known spamming hosts
for IP in $( cat $FILE_UNZIPPED | egrep -v '^;' | awk '{ print $1}' ); do

    # add the ip address to the chain
    ipset add $SET $IP

    #echo $IP

done
#Add the list with one iptables line
$IPTABLES -I INPUT -m set --match-set $SET src -j DROP


echo "Done!"

# remove the spam list
unlink $FILE
unlink $FILE_UNZIPPED
