#Author: uniquegeek@gmail.com
#Purpose: copy files from local workstations' temp generated by GPOtime.bat to your temp
#Input: $list of workstations
#Output: files in your temp named gptime-*

function Copy-GPtimeFiles {
$list = "computers.txt"
$listdir = "c:\users\yourusername\documents\"

Write-Host "$list"
    Get-Content "$listdir$list" | 
        foreach {
            if (-not (Test-Connection -comp $_ -quiet)){
                Write-host "$_ is down" -ForegroundColor Red
            } Else {
                Copy-Item \\$_\c$\temp\gptime* C:\temp
                write-host "File copied from $_"
            }
        }
}

Copy-GPtimeFiles
