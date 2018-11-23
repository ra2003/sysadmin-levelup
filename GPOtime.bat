REM uniquegeek@gmail.com
REM Purpose: GPO Troubleshooting. Helpful for time issues and Kerberos tickets.
REM    Also helpful for troubleshooting intermittent GPO issues using several workstations.
REM Input: nothing
REM Output: time of workstation, time of your dc's, results of gpupdate, and server used for GP processing
REM    results are in c:\temp\gptime-hostname.txt
REM Directions: Run as user on a workstation with your automation method of choice (GPO, PowerShell, automation framework...)
REM    Replace your1stdc etc. with your dc hostnames.
REM ------------------------------------------------
@echo off
echo.|time > c:\temp\gptime-%COMPUTERNAME%.txt
echo ========================================== >> c:\temp\gptime-%COMPUTERNAME%.txt
net time \\your1stdc >> c:\temp\gptime-%COMPUTERNAME%.txt
net time \\your2nddc >> c:\temp\gptime-%COMPUTERNAME%.txt
net time \\your3rddc >> c:\temp\gptime-%COMPUTERNAME%.txt
echo ========================================== >> c:\temp\gptime-%COMPUTERNAME%.txt
gpupdate /force >> c:\temp\gptime-%COMPUTERNAME%.txt
echo ========================================== >> c:\temp\gptime-%COMPUTERNAME%.txt
gpresult /r >> c:\temp\gptime-%COMPUTERNAME%.txt
