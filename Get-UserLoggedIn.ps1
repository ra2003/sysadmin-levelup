#Get a list of computers you now aren't in use
#so you can work on them and follow up with patches etc.

function Get-UserLoggedIn {

    Get-Content "c:\users\you\documents\computers.txt" | 
        foreach {
            if (-not (Test-Connection -comp $_ -quiet)){
                Write-host "$_ is down" -ForegroundColor Red
            } Else {
                $users = Get-WmiObject -Class win32_computersystem -Property username -ComputerName $_
                if ($users.username){
                    $user = $users.username.ToString()
                    write-host "$_ $user logged in"
                } else {
                    Write-host "$_ No User Logged In" -ForegroundColor Green
                }
            }
        }
}

get-UserLoggedIn
