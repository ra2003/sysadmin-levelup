#uniquegeek@gmail.com
#Input: text list of hostnames
#Output: csv file of whether machine is on, hostname, username (if logged in), x, y (of all screens)

#this script isn't writing the machines that give Access_Denied anymore
#works otherwise

# https://stackoverflow.com/questions/7967699/get-screen-resolution-using-wmi-powershell-in-windows-7
# Get-WmiObject -Class win32_desktopmonitor | Select-Object screenwidth,screenheight
# $temp = Get-WmiObject -Class win32_videocontroller | Select-Object videomodedescription

function Get-ScreenResolution {
    $outfile = "c:\users\you\documents\Get-ScreenResolution-Output.txt"
    Write-Host "Online,Hostname,Username,x,y"
    #Add-Content -path $outfile -value "Online,Hostname,Username,x,y"
    Out-file -FilePath $outfile -InputObject "Online,Hostname,Username,x,y"

    Get-Content "c:\users\you\documents\computers.txt" | 
        foreach {
            if (-not (Test-Connection -comp $_ -quiet)){
                Write-host "down,$_,nil,nil,nil"
                Out-File -FilePath $outfile -Append -InputObject "down,$_,nil,nil,nil"
            } Else {
                $lasterror = $null
                try {
                    $users = Get-WmiObject -Class win32_computersystem -Property username -ComputerName $_
                } catch {
                    $lasterror = $error[0].Exception.HResult
                    #Write-Host "$lasterror"
                }
                #HRESULT: 0x80070005 (E_ACCESSDENIED) is -2147024891
                if ($lasterror -eq -2147024891){
                    $user = "AccessDenied"
                } elseif ($users.username){
                    $user = Split-Path ($users.username.ToString()) -leaf
                } else {
                    $user = "NoUser"
                }
                #sizes is an array of PSCustomObjects (which is key = value pairs, i.e. a hashtable)
                $sizes = $null
                try {
                    $sizes = Get-WmiObject -Class win32_videocontroller -ComputerName $_ | Select-Object VideoModeDescription
                } catch {
                }
                $screens = $sizes.count

                #$screens not written because VideoController objects also includes display ports not in use
                #not important enough right now to dig deeper
                #write-host "$screens," -NoNewline                
                if ($screens -eq $null) {
                    Out-File -FilePath $outfile -Append -InputObject "up,$_,$user,nil,nil"
                    Write-Host "up,$_,$user,nil,nil"
                }

                for($i=0; $i -lt $screens; $i++){
                    $resolution = $sizes[$i].VideoModeDescription
                    if ($resolution -ne $null) {
                        $values = $resolution.Split(" ")
                        $x = $values[0]
                        $y = $values[2]
                        Out-File -FilePath $outfile -Append -InputObject "up,$_,$user,$x,$y"
                        #Add-Content -path $outfile "up,$_,$user,$x,$y"
                        Write-host "up,$_,$user,$x,$y"
                    }
                }
                #$temp | ForEach-Object {
                #    write-host "$_.videomodescription.ToString()" -NoNewline
                #} 
                #write-host ""                
            }
        }
}

get-ScreenResolution
