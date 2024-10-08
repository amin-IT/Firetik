Update: New domain at www.binary.ph

# Firetik
Mikrotik Firewall - A RouterOs script to block a dynamic list of malicious IPs from Firehol_level1



My Firetik script is automatically maintained via a VBScript that gets a list of malicious IPs from firehol_level1 
and translates it to RouterOs script. I host the script at https://binary.ph/firehol/firehol.rsc. 
The output rsc file is synchronized from my personal computers via ftp which my vbscript updates regularly triggered by task scheduler. 

The script works like an Antivirus for your network that blocks malicious IPs with Firehol_Level1's dynamic list as your database.

You can learn more about the list here: http://iplists.firehol.org/

IMPLEMENTATION:

Code: (copy each block and paste it to terminal)
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

name="DownloadFireholList" on-event=DownloadFirehol start-date=jan/01/1970 start-time=08:51:27

/system scheduler add comment="Apply Firehol list" interval=1d \

name="InstallFireholList" on-event=ReplaceFirehol start-date=jan/01/1970 start-time=08:56:27

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

#To effectively apply the blocklists, it's recommended to target the internet-facing interface rather than implementing a global block, 
as the list contains private IPs. This ensures that the specified IP addresses are blocked solely on your WAN connection. For instance, 
if the internet connection is on ether1, set the Out. Interface to ether1. For setups with multiple internet connections, 
you can create an interface list under Interfaces > List, name it WAN, and use this list in the Out. Interface List field.
    
------------------------------------------------------------------------------------------------------------------------------

#Thanks to Joshaven for sharing his automated scripts and to Firehol.org for sharing their dynamic list of malicious IPs
