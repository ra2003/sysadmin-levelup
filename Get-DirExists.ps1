#in progress

function Get-DirExists {

    Get-Content "c:\users\kscrupa\documents\trainingroom.txt" | 
        foreach {
            if (-not (Test-Connection -comp $_ -quiet)){
                Write-host "$_ is down" -ForegroundColor Red
            } Else {
                $users = Get-WmiObject -Class win32_computersystem -Property username -ComputerName $_
                $exists = Get-WmiObject -Class win32_directory -Filter "name='c:\\program files (x86)\\adobe\\acrobat reader dc'" -ComputerName $_
                if ($exists){
                    $user = $users.username.ToString()
                    write-host "$_ t logged in"
                } else {
                    Write-host "$_ t No User Logged In" -ForegroundColor Green
                }
            }
        }
}

get-DirExists
