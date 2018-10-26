#Author: uniquegeek@gmail.com
#Input: txt file of hostnames, one per line
#Output: hostname, who's logged in, javaversion (which is a folder)
#   Note that if there are previous versions installed, or remains of folders from old installs
#   this script lists them both.
#   Intend to make the distinction and improve this script later.

function Get-FileVersion-Java {
$list = "computers.txt"
$listDir = "c:\users\you\documents\" #list location
$currVer = "jre1.8.0_192"
$okVer = "jre1.8.0_191"

Write-Host "$list"

    Get-Content "$listdir$list" | 
        foreach {
            $users = $null
            $javaver = $null
            $user = $null
            if (-not (Test-Connection -comp $_ -quiet)){
                $user = "unknown"
                $javaver = "unknown"
                Write-host "$_,$user,$javaver" -ForegroundColor Red
            } Else {
                $users = Get-WmiObject -Class win32_computersystem -Property username -ComputerName $_
                if ($users.username -eq $null) {$user="none"}
                
                $javaver = Get-ChildItem "\\$_\c$\Program Files (x86)\Java" -Filter jre* -name
                
                if ($javaver -eq $null) {$javaver="none"}
                $javaString = $javaver -join " "  #convert from array of values for proper testing
                
                if (($users.username) -and ($javaString -ne $currver) -and ($javaString -ne "$okVer $currver")){
                    $user = Split-Path $users.username.ToString() -Leaf
                    write-host "$_,$user,$javaString" -ForegroundColor Green
                } else {
                    if (($users.username -eq $null) -and ($javaString -ne $currver) -and ($javaString -ne "$okVer $currver")) {
                        Write-host "$_,$user,$javaString"
                    }
                }
            }
        }
}

Get-FileVersion-Java
