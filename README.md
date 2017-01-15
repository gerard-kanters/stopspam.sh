Stops spammers from flooding your mail or accessing your site with a single firewall rule. It takes about 2MB of memory and has no measurable impact on performance.

This script downloads a list of 150.000 known spammers to add to your firewall (iptables). Normally this would make iptables slow and therefore your site as well. I used ipset http://ipset.netfilter.org/ipset.man.html to create the list and add a single iptables rule to match the set.

The script is made for Centos/Redhat but can be easily adapted for other Linux distro's. Just change the line to reload iptables. 

Usage:
Copy/paste the script or download it in /etc/cron.daily and make it executable "chmod +x /etc/cron.daily/stopspam.sh"

The list can only be downloaded twice a day, so if you are testing it will  give you a message after 2 runs that you reached the maximum number of downloads. This will not effect the working, the rule and set keep on working. 

Want to see if it worked ?
After running the script you can use "ipset -L|wc -l" and you should see something like 153381. This is the number of spam ip addresses added to the firewall.

use "iptables -S" to see if the firewall rule is added. somewhere in the top of the list you see "-A INPUT -m set --match-set Stopforumspam src -j DROP" 

You can reuse this script to add daily spammers in hourly cron. Adapt the script, use another SET name and put it in /etc/cron.hourly.
Beware that you should not reload iptables, since that would remove this list as well. Just run it without reloading. 
