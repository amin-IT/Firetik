# Firetik
A RouterOs (Mikrotik) script to block a dynamic list of malicious IPs from Firehol_level1



My Firetik script is automatically maintained via a VBScript that gets a list of malicious IPs from firehol_level1 
and translates it to RouterOs script. I host the script at https://amin-firetik.000webhostapp.com/firehol/firehol.rsc. 
The output rsc file is synchronized from my personal computers via ftp which my vbscript updates regularly triggered by task scheduler. 

The script works like Malwarebytes Website Protection for your network but the list of malicious IPs is from Firehol_level1
which they update on a regular basis.
You can find it here: https://raw.githubusercontent.com/ktsaou/blocklist-ipsets/master/firehol_level1.netset

IMPLEMENTATION:

Code: (copy each block and paste it to terminal)
------------------------------------------------------------------------------------------------------------------------------
# Script which will download the drop list as a text file
------------------------------------------------------------------------------------------------------------------------------

/system script add name="DownloadFirehol" source={
/tool fetch url="https://amin-firetik.000webhostapp.com/firehol/firehol.rsc" mode=https;
}

------------------------------------------------------------------------------------------------------------------------------
# Script which will Remove old Firehol list and add new one
------------------------------------------------------------------------------------------------------------------------------

/system script add name="ReplaceFirehol" source={
/ip firewall address-list remove [find where comment="firehol"]

/import file-name=firehol.rsc;}

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


After copy/pasting the scripts above, add a drop rule for Dst. Address List firehol in forward chain BELOW the accept rule for established, related, untracked connections (defconf). OR you can copy the script below which will create the drop rule and check the connection-state=new.

This way established connections will be accepted immediately and it will disregard the firehol address list on its 2nd cycle to the filter rules. Meaning, the long firehol address list will have no impact on the performance of your router once the connection passed the 1st cycle.

------------------------------------------------------------------------------------------------------------------------------
# Script to add the firehol list in Firewall Filter Rules
------------------------------------------------------------------------------------------------------------------------------

/ip firewall filter

add chain=forward action=drop comment="Firehol list" connection-state=new dst-address-list=firehol
    
------------------------------------------------------------------------------------------------------------------------------

#Thanks to Joshaven for sharing his automated scripts and to Firehol.org for sharing their dynamic list of malicious IPs
