#in progress
#n.b. lack of force switch means these only reboot if no one is logged in

function RestartComputers-NoForce {

    Get-Content "c:\users\you\documents\computers.txt" | 
        foreach {
            if (-not (Test-Connection -comp $_ -quiet)){
                Write-host "$_ is down" -ForegroundColor Red
            } Else {
                $status = Restart-Computer $_
                if ($status){
                    write-host "$_ restarted"
                } else {
                    Write-host "$_ unable to restart" -ForegroundColor red
                }
            }
        }
}

restartComputers-NoForce
