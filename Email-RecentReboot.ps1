#Author: uniquegeek@gmail.com
#Input: none
#Output: emails the most recent reboot time (down/up) that occoured within cronWindow timeframe
#Directions: run as a Windows scheduled task, or attach to an eventviwer event

function Email-RecentReboot {
#---treat like static vars
#run this script at the frequency selected here
$cronWindow = 60
$PSEmailServer = "mail.yourdomain.com"
$EmailFrom = "noreply@yourdomain.com"
$EmailTo = "helpdesk@yourdomain.com"

#search for "Using PSCredentials without a prompt" and Get-Credential for more info:
$svcAccount = $svcCred 

#don't edit these three
$cronUnits = "minutes" #code below will need changes if you change this from minutes
$currTime = Get-Date
$pc = $env:COMPUTERNAME
#---end static vars

#PS 5+
#$OStype = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name "ProductName"
#$OSrelease = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name "ReleaseID"
#$OSbuild = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name "CurrentBuild"

#PS 4 and other
$OStype = $((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName)
$OSversion = $((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentVersion)
$OSrelease = $((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseID)
$OSbuild = $((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild)

$downEvent = Get-Eventlog -LogName System -Newest 1 -InstanceId 2147489654 | Select-Object TimeGenerated
$downTime = $downEvent[0].TimeGenerated.ToString()
$upEvent = Get-Eventlog -LogName System -Newest 1 -InstanceId 2147489653 | Select-Object TimeGenerated
$upTime = $upEvent[0].TimeGenerated.ToString()

#subtract cronTime minutes from currTime
$cutoff = $currTime.AddMinutes(-$cronWindow)

if (($cutoff -le $downEvent[0].TimeGenerated) -or ($cutoff -le $upEvent[0].TimeGenerated)) {
    $Subject = "Server Reboot $pc - $OStype v$OSversion r$OSrelease b$OSbuild"
    $body1 = "Server power event initiated within last $cronWindow $cronUnits."
    $body2 = "Last shutdown $downTime."
    $body3 = "Last bootup $upTime."
    $body = "$body1<br/>$body2<br/>$body3"
    Send-MailMessage -To $EmailTo -From $EmailFrom -Subject $Subject -Body "$body" -BodyAsHtml -SmtpServer $PSEmailServer -Credential $svcaccount
    }
}

Email-RecentReboot
