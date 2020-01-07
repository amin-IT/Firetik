# Firetik
A RouterOs script (Mikrotik) to block malicious IPs listed on Firehol_level1



My Firetik script is automatically maintained via a VBScript that gets a list of malicious IPs from firehol_level1 
and translates it to RouterOs script. I host the script at https://amin-firetik.000webhostapp.com/firehol/firehol.rsc. 
The output rsc file is synchronized from my personal computers via ftp which my vbscript updates regularly triggered by task scheduler daily. 

The script works like Malwarebytes Website Protection for your network but the list of malicious IPs is from Firehol_level1
which you can find here: https://raw.githubusercontent.com/ktsaou/blocklist-ipsets/master/firehol_level1.netset

IMPLEMENTATION:

Code: (copy/paste to terminal)
# Script which will download the drop list as a text file
/system script add name="DownloadFirehol" source={
/tool fetch url="https://amin-firetik.000webhostapp.com/firehol/firehol.rsc" mode=https;
}

# Script which will Remove old Firehol list and add new one
/system script add name="ReplaceFirehol" source={
/ip firewall address-list remove [find where comment="firehol"]
/import file-name=firehol.rsc;
}

# Schedule the download and application of the Firehol list
/system scheduler add comment="Download Firehol list" interval=1d \
name="DownloadFireholList" on-event=DownloadFirehol \
start-date=jan/01/1970 start-time=08:51:27
/system scheduler add comment="Apply Firehol list" interval=1d \
name="InstallFireholList" on-event=ReplaceFirehol \
start-date=jan/01/1970 start-time=08:56:27

# Script to run the DownloadFirehol script for initial setup
/system script run DownloadFirehol

# Script to run the ReplaceFirehol script for initial setup
/system script run ReplaceFirehol

After copy/pasting the scripts above, add a drop rule for Dst. Address List firehol in forward chain BELOW the accept rule for established, related, untracked connections (defconf). OR you can check the connection-state=new on the firehol drop rule. It should look like this:

# Script to add the firehol list in Firewall Filter Rules

/ip firewall filter

add chain=forward action=drop comment="Firehol list" connection-state=new dst-address-list=firehol
    
This way established connections will be accepted immediately and it will disregard the firehol address list which will minimize
the impact of the long address list on the performance of your Mikrotik router

#Thanks to Joshaven for sharing his automated scripts and to Firehol.org for sharing their list of malicious IPs
