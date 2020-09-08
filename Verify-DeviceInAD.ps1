#uniquegeek@gmail.com
#Purpose: report whether a list of PC's has been seen in AD recently, to assist with reporting and cleanup.
#Input: List of computer names in "Verify-DeviceInAD-input.txt"
#Output: "hostname,IPaddress,TimeLastSeeninAD,Dept,Branch"; devices not in AD are greyed out
#Note: you may need to change array indices to match the OU you need from the DN, see comments below

function Verify-DeviceInAD {

    $list = 'Verify-DeviceInAD-input.txt'
    $listdir = 'c:\users\yourusername\documents\'

    Write-host "hostname,Ping,LastSeenAD,Dept,Branch"

    Get-Content "$listdir$list" | foreach {
        $comp = $_
        $up = 'NoPing'
        $dept = $branch = 'NotInAD'
        $lastseen = 'None'
        try {
            if ($p = test-connection $comp -Count 1 -ErrorAction SilentlyContinue) {
                $up = $p.ProtocolAddress
            }
        } catch {
            $up = 'NoPing'
        }
        try {
            if ($c = Get-ADComputer $comp -Properties lastlogondate) {
                $dn = $c.DistinguishedName
                $items = $dn.Split(",")
                #get name the second RDN (index 1), which happens to be an OU named by department
                $dept = $items[1]
                $pos = $dept.IndexOf("=")
                $dept = $dept.Substring($pos+1)
                    
                #set array index of branch OU, 3 is most computers (4th OU in DN)
                # index needed will vary by your org's OU structure
                $i = "3"
                if ($dept -eq 'SpecialOU1') { $i=2 }
                if (($dept -eq 'SpecialSubOU2') -or ($dept -eq 'SpecialSubOU3')) { $i=4 }
                
                $branch = $items[$i]
                $pos = $branch.IndexOf("=")
                $branch = $branch.Substring($pos+1)

                $lastseen = $c.LastLogonDate
                $lastseen = $lastseen.GetDateTimeFormats()[5]
            }
        } catch {
            Write-host "$comp,$up,$lastseen,$dept,$branch" -ForegroundColor Gray
        }
        Write-host "$comp,$up,$lastseen,$dept,$branch"
    }    
}

Verify-DeviceInAD
