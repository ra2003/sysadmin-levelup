#uniquegeek@gmail.com
#this script uninstalls all but the newest version x86 java
#if no java, does nothing
#only tested with 8u series
#note java guids have version number near end, i.e. 80261 is 8u261
#{26A24AE4-039D-4CA4-87B4-2F32180261F0}"

#for use with x64 in the future:
#$javaVer = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -match "Java 8 Update" } | Select-Object -Property DisplayName, UninstallString

#get all java uninstall strings
$javaVer = Get-ChildItem -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -match "Java 8 Update" } | Select-Object -Property DisplayName, UninstallString

#if you have one java, $javaVer gives a System.Object type, don't uninstall
#two or more Java verions gives System.Array type
$isarray = $javaVer -is [array]
#determine if we only need to uninstall one java
$one_old = ($javaVer.Length) -eq 2 
if ($isarray) {
    if ($one_old) {
        $uninst = $javaVer[0].UninstallString
		Start-Process cmd -ArgumentList "/c $uninst /quiet /norestart" -Verb RunAs -Wait
    } else {
        $javaVer = $javaVer[0..($javaVer.Length-2)]
        ForEach ($ver in $javaVer) {
        	If ($ver.UninstallString) {
		        $uninst = $ver.UninstallString
		        Start-Process cmd -ArgumentList "/c $uninst /quiet /norestart" -Verb RunAs -Wait
		    }
        }
    }
 }
