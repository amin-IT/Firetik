Update: New domain at [www.binary.ph](https://binary.ph/mikrotik-firewall-enhance-network-security/)

# Firetik

Firetik is a MikroTik firewall script that blocks known malicious IP addresses using a daily-updated blocklist built from [FireHOL](https://iplists.firehol.org/) Levels 1–4:

- Level 1 – the core, safest list:
  - Fullbogons: IP ranges that should never appear on the internet (unallocated and private ranges)
  - Spamhaus DROP: networks controlled by spammers and cybercriminals (now includes the former EDROP list)
  - DShield: the top 20 attacking /24 networks of the last 3 days
  - Malware C&C lists: command-and-control servers used by malware
- Level 2 – IPs seen attacking in roughly the last 48 hours
- Level 3 – IPs seen attacking, spamming or hosting malware in roughly the last 30 days
- Level 4 – a more aggressive list that may occasionally block legitimate IPs

The firewall rule blocks devices on your network from opening new connections to these addresses, which helps stop malware from calling home and users from reaching known malicious hosts.

## Setup

Copy each block and paste it into the MikroTik terminal.
------------------------------------------------------------------------------------------------------------------------------
# Script which will download the drop list as a text file
------------------------------------------------------------------------------------------------------------------------------

/system script add name="DownloadFirehol" source={
/tool fetch url="https://binary.ph/firehol/firehol.rsc" mode=https;
}

------------------------------------------------------------------------------------------------------------------------------
# Script which will Remove old Firehol list and add new one
------------------------------------------------------------------------------------------------------------------------------

/system script add name="ReplaceFirehol" source={/file

:global firehol [/file get firehol.rsc contents];
:if (firehol != "") do={/ip firewall address-list remove [find where comment="firehol"]

/import file-name=firehol.rsc;}}

------------------------------------------------------------------------------------------------------------------------------
# Schedule the download and application of the Firehol list
------------------------------------------------------------------------------------------------------------------------------

/system scheduler add comment="Download Firehol list" interval=1d \

name="DownloadFireholList" on-event="/system script run DownloadFirehol" start-date=jan/01/1970 start-time=08:51:27

/system scheduler add comment="Apply Firehol list" interval=1d \

name="InstallFireholList" on-event="/system script run ReplaceFirehol" start-date=jan/01/1970 start-time=08:56:27

------------------------------------------------------------------------------------------------------------------------------
# Run the DownloadFirehol script for first-time setup
------------------------------------------------------------------------------------------------------------------------------

/system script run DownloadFirehol

------------------------------------------------------------------------------------------------------------------------------
# Run the ReplaceFirehol script for first-time setup
------------------------------------------------------------------------------------------------------------------------------

/system script run ReplaceFirehol

------------------------------------------------------------------------------------------------------------------------------
# Script to add the firehol list in Firewall Filter Rules
------------------------------------------------------------------------------------------------------------------------------

/ip firewall filter

add chain=forward action=drop comment="Firehol list" connection-state=new dst-address-list=firehol

#Limit the rule to your WAN (important)

The list includes private IP ranges, so without this step the rule can block traffic inside your own network. Open the "Firehol list" rule and set Out. Interface to your internet port (e.g. `ether1`). With multiple internet connections, create an interface list named `WAN` (Interfaces → Interface List), add your WAN ports to it, and set Out. Interface List to `WAN` instead.


![image](https://github.com/user-attachments/assets/8602f11e-8ccc-437a-a124-cb13e4fb20fc)

------------------------------------------------------------------------------------------------------------------------------

## More

- IPv6 firewall: https://binary.ph/ipv6
- Need help applying other FireHOL levels? Contact me via the [About page](https://binary.ph/about/).
  
------------------------------------------------------------------------------------------------------------------------------

*Thanks to Joshaven for his automation scripts and to FireHOL.org for maintaining the blocklists.*
