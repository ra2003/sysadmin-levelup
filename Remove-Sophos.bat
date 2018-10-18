@echo off
REM uniquegeek@gmail.com
REM Uninstalls all pieces of Sophos Anti-Virus without rebooting.
REM Deploy the three Uninstall registry keys from Sophos KB 109668 first via GPO.
REM Uninstalling Sophos Anti-Virus with wmic causes a reboot. Using msiexec instead we can control it.
REM (grab the GUIDs for Anti-Virus and Remote Management from your matching Uninstall registry key and replace it below)
REM
REM echo "stop services"
net stop "sophos agent"
net stop SAVService
net stop savadminservice
net stop "Sophos AutoUpdate Service"
net stop "Sophos Message Router"
net stop "SntpService"
net stop sophossps
net stop "Sophos Web Control Service"
net stop swi_service
net stop swi_update_64
net stop "Sophos client firewall"
net stop "Sophos client firewall manager"
REM stop remote management service (same as Start=dword:00000004)
sc config "Sophos Agent" start= disabled
REM echo "remote mgmt"
REM Sometimes this doesn't work
C:\Windows\System32\wbem\wmic.exe product where "name like '%%sophos remote management%%'" call uninstall /nointeractive
ping -n 21 127.0.0.1 > nul
REM This call tends to work better
REM echo "remote mgmt msiexec"
MsiExec.exe /qn /norestart /X{FED1005D-CBC8-45D5-A288-FFC7BB304121}
ping -n 21 127.0.0.1 > nul
REM echo "system protection"
C:\Windows\System32\wbem\wmic.exe product where "name like '%%sophos system protection%%'" call uninstall /nointeractive
ping -n 21 127.0.0.1 > nul
REM echo "network threat"
C:\Windows\System32\wbem\wmic.exe product where "name like '%%sophos network threat%%'" call uninstall /nointeractive
ping -n 21 127.0.0.1 > nul
REM Endpoint Defense tends to stay in the menu. Installer is actually an exe. Sometimes the wmic command uninstalls it, though.
REM echo "endpoint defense"
C:\Windows\System32\wbem\wmic.exe product where "name like '%%sophos endpoint defense%%'" call uninstall /nointeractive
ping -n 21 127.0.0.1 > nul
REM echo "endpont defense exe"
if exist "C:\Program Files\Sophos\Endpoint Defense\uninstall.exe" ("C:\Program Files\Sophos\Endpoint Defense\uninstall.exe" /q)
ping -n 21 127.0.0.1 > nul
if exist "C:\Program Files\Sophos\Endpoint Defense\uninstall.exe" (del "C:\Program Files\Sophos\Endpoint Defense\uninstall.exe")
if exist "C:\Program Files\Sophos\Endpoint Defense" (rmdir "C:\Program Files\Sophos\Endpoint Defense")
REM echo "client firewall"
C:\Windows\System32\wbem\wmic.exe product where "name like '%%sophos client firewall%%'" call uninstall /nointeractive
ping -n 21 127.0.0.1 > nul
REM echo "autoupdate"
C:\Windows\System32\wbem\wmic.exe product where "name like '%%sophos autoupdate'" call uninstall /nointeractive
ping -n 21 127.0.0.1 > nul
REM Removing Sophos Anti-Virus causes a reboot if you use wmic. Use msiexec instead.
REM echo "anti-virus msiexec"
MsiExec.exe /qn /norestart /X{65323B2D-83D4-470D-A209-D769DB30BBDB}
ping -n 21 127.0.0.1 > nul
SC DELETE "sophos agent"
SC DELETE SAVService
SC DELETE savadminservice
SC DELETE "Sophos AutoUpdate Service"
SC DELETE "Sophos Message Router"
SC DELETE "SntpService"
SC DELETE sophossps
SC DELETE "Sophos Web Control Service"
SC DELETE swi_service
SC DELETE swi_update_64
SC DELETE "Sophos client firewall"
SC DELETE "Sophos client firewall manager"
