#Author: uniquegeek@gmail.com
#Input: txt file of hostnames, one per line
#Output: hostname, who's logged in, bad GPO events (time, id, messagetext of Group Policy error, warning, and critical)
#    Gets written on screen as well as exported to a csv

function Get-LastGPOBad {
$hours = "48"
$listName = "computers.txt"
$listDir = "c:\users\you\documents\"
$lineLen = 50  #choose output length on screen to prevent wrapping

$outName = "Get-LastGPOBad.csv"
$outDir = $listDir
$outFile = "$outDir$outName"

$logType = "Microsoft-Windows-GroupPolicy/Operational" #treat as static var for this function
$date = (Get-Date).Addhours(-$($hours))

Write-Host "$listName"

    Get-Content "$listDir$listName" | 
        foreach {
            $users = $null
            $user=$gpoEvents=$t=$n=$i=$m="unknown"
            $compName = $_
            $event = @()

            if (-not (Test-Connection -comp $compName -quiet)){
                Write-host "$compName,$user,$t,$n,$i,$m" -ForegroundColor Red
            } Else {
                #(Get-WinEvent -ListLog Application).ProviderNames
                $gpoEvents = Get-WinEvent -FilterHashtable @{ LogName = $logType ; StartTime = $date; level=@(1,2,3) } -ComputerName $compName -Oldest
                $users = Get-WmiObject -Class win32_computersystem -Property username -ComputerName $compName
                if ($users.username -eq $null) {
                    $user="none"
                } else {
                    $user = Split-Path $users.username.ToString() -Leaf #strip domain off
                }
                $gpoEvents | foreach {
                    $t = $_.TimeCreated
                    $n = $_.LevelDisplayName
                    $i = $_.Id
                    $m = $_.Message.Replace("`n"," ")
                    
                    $mshort = $m.SubString(0,[System.Math]::Min($lineLen,$m.Length))
                    write-host "$compName,$user,$t,$n,$i,$mshort"
                    $event = @()
                    $event += New-Object psobject -Property @{Hostname=$compname;Username=$user;Time=$t;Name=$n;ID=$i;Message=$m}
                    $event | Export-Csv -Path $outfile -Append
                }
            }
        }
}

Get-LastGPOBad
