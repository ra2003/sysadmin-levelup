#uniquegeek@gmail.com
#this script uninstalls all but a specific x86 java
#if no java, does nothing
#only tested with Java JRE 8u series

#CHANGE THIS VARIABLE TO GUID YOU DON'T WANT UNINSTALLED
#notice it has 80261 near end, which is 8u261
$curr_x86= "{26A24AE4-039D-4CA4-87B4-2F32180261F0}"

#for use with multi archiectures in the future:
#$javaVer = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -match "Java 8 Update" } | Select-Object -Property DisplayName, UninstallString

#get all java uninstall strings
$javaVer = Get-ChildItem -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -match "Java 8 Update" } | Select-Object -Property DisplayName, UninstallString

#one java gives a System.Object type, don't uninstall
#two or more Java verions gives System.Array type
$multi = $javaVer -is [array]
if ($multi) {
    ForEach ($ver in $javaVer) {
    	If (($ver.UninstallString) -and ($ver.UninstallString -notmatch $curr_x86)) {
		    $uninst = $ver.UninstallString
		    Start-Process cmd -ArgumentList "/c $uninst /quiet /norestart" -Verb RunAs -Wait
		}
    }
 }
 
