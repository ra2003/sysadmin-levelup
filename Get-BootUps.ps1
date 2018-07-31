#Input: Takes a hostname and number of x results you would like
#Output: a list of the last x times the computer booted up

param( [string]$h, [int]$x)

function Get-BootUps {
    if (-not (Test-Connection -comp $h -quiet)){
        Write-host "$h is down" -ForegroundColor Red
    } Else {
        Get-Service -Name RemoteRegistry -ComputerName $h | Set-Service -Status Running
        Start-Sleep -Seconds 5
        $startups = Get-Eventlog -LogName System -Newest $x -InstanceId 2147489653 -ComputerName $h | Format-List TimeGenerated
        write-host $startups
    }
}

Get-Bootups -h $h, -x $x
