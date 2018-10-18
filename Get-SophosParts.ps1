#uniquegeek@gmail.com
#Input: computers.txt in same directory
#Output: List of computers,user logged in, which remnants of Sophos Anti-Virus exists
#
# The file or folder we're checking is in the $destination variable

function Get-SophosParts {

    Get-Content "computers.txt" | 
        foreach {
            if (-not (Test-Connection -comp $_ -quiet)){
                Write-host "$_ is down" -ForegroundColor Gray
            } Else {
                $piecesremaining = "False"
                $user = "No-User"
                #TODO: convert next line into try/catch for RPC server unavailable errors (HRESULT: 0x800706BA)
                $users = Get-WmiObject -Class win32_computersystem -Property username -ComputerName $_
                $test1 = Test-Path "\\$_\c$\program files (x86)\sophos\Remote Management System\ManagementAgentNT.exe"
                $test2 = Test-Path "\\$_\c$\program files (x86)\sophos\sophos anti-virus\savadminservice.exe"
                $test3 = Test-Path "\\$_\c$\program files (x86)\sophos\sophos system protection"
                $test4 = Test-Path "\\$_\c$\program files (x86)\sophos\autoupdate"
                $test5 = Test-Path "\\$_\c$\Program Files (x86)\Sophos\Client Firewall"
                $test6 = Test-Path "\\$_\c$\program files\sophos\endpoint defense\uninstall.exe"
                $test7 = Test-Path "\\$_\c$\program files\sophos\sophos network threat protection"
                $piecesremaining = ($test1 -or $test2 -or $test3 -or $test4 -or $test5 -or $test6 -or $test7)
                if ($piecesremaining){
                    $pieces = @{ "RemoteMgmt" = "$test1"; "Anti-Virus" = "$test2"; "SysProtect" = "$test3"; "AutoUpdate" = "$test4"; "Firewall" = "$test5"; "EndptDefense" = "$test6"; "NetworkThreat" = "$test7"}
                    write-host "$_," -NoNewline
                    if ($users.username) {
                        $user = Split-Path ($users.username.ToString()) -leaf                        
                        write-host "$user," -NoNewline -ForegroundColor red
                    } else {
                        write-host "$user," -NoNewline -ForegroundColor green
                    }
                    #this comment for testing: Write-Host "$test1,$test2,$test3,$test4,$test5,$test6,$test7"
                    #foreach & hashtable https://stackoverflow.com/questions/9015138/looping-through-a-hash-or-using-an-array-in-powershell
                    foreach ($h in $pieces.GetEnumerator()) {
                        $piece = $($h.name)
                        if ($($h.value) -eq $true) {
                            if ($piece -eq "AutoUpdate") {
                                write-host "$piece" 
                            } else {
                                write-host "$piece," -NoNewline
                            }
                        } else {
                        #if not true:
                        if ($piece -eq "AutoUpdate") {
                                write-host "x"
                            } else {
                                write-host "x," -NoNewline
                            }
                       
                        }
                    
                    }
                    
                }                
            }
        }
}

Get-SophosParts
