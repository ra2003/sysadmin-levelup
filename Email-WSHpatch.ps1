#Author: uniquegeek@gmail.com
#Input: none
#Output: emails most recent beginning and end times (and KBs) of 
#    WSH patches within cronWindow timeframe
#Directions: run this as a Windows scheduled task every cronWindow minutes, or attach to an eventviwer event

function Email-WSHpatch {
#---treat like static vars
#run this script at the frequency selected here
#begin static vars
$cronWindow = 60
$cronUnits = "minutes"
$PSEmailServer = "mail.yourdomain.com"
$EmailFrom = "noreply@yourdomain.com"
$EmailTo = "helpdesk@yourdomain.com"

#see "Using PSCredentials without a prompt" and Get-Credential
$svcAccount = $svcCred

$currTime = Get-Date
$cutoff = $currTime.AddMinutes(-$cronWindow)

$pc = $env:COMPUTERNAME

$installMsg = "The install was performed successfully."
$deleteMsg = "The file was deleted successfully."
#---end static vars

$patchFinished = $false

#PS 5+
#$OStype = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name "ProductName"
#$OSrelease = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name "ReleaseID"
#$OSbuild = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name "CurrentBuild"

#PS 4 and legacy
$OStype = $((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName)
$OSversion = $((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentVersion)
$OSrelease = $((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseID)
$OSbuild = $((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild)

#get last WSH patch event
$wshPatchStart = Get-Eventlog -LogName Application -Newest 40 -Source WSH | Where-Object -FilterScript {$_.Message -like "*$installMsg*"}
$sTime = $wshPatchStart[0].TimeGenerated.toString()
$sKB = [regex]::Match($wshPatchStart[0].Message, 'File Name: (.+)\n').Groups[1].value

$wshPatchEnd = Get-Eventlog -LogName Application -Newest 40 -Source WSH | Where-Object -FilterScript {$_.Message -like "*$deleteMsg*"}
$eTime = $wshPatchEnd[0].TimeGenerated.toString()
#$eKB = Split-Path $wshPatchEnd[0].Message -leaf #gives extra whitespace garbage in object, don't use
$eKB = [regex]::Match($wshPatchEnd[0].Message, 'File Name: (.+)\n').Groups[1].value

if (($wshPatchEnd[0].Index -gt $wshPatchStart[0].Index) -and ($sKB -eq $eKB)) {
    $patchFinished=$true
} else {
    $patchFinished=$false
}
   
if (($wshPatchStart[0].TimeGenerated -ge $cutoff) -or ($wshPatchEnd[0].TimeGenerated -ge $cutoff)) {
    $Subject = "Security Patching $pc $OStype v$OSversion r$OSrelease b$OSbuild"
    $body1 = "WSH Patch initiated within last $cronWindow $cronUnits."
    $body2 = "Last patch start $sKB at $sTime."
    $body3 = "Last patch end $eKB at $eTime."
    $body4 = "Patch is finished: $patchFinished."
    $body = "$body1<br/>$body2<br/>$body3</br/>$body4"
    Send-MailMessage -To $EmailTo -From $EmailFrom -Subject $Subject -Body "$body" -BodyAsHtml -SmtpServer $PSEmailServer -Credential $svcAccount
    }
}

Email-WSHpatch
