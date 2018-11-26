#Author: uniquegeek@gmail.com
#Input: txt file of hostnames, one per line
#Output: hostname, who's logged in, javaversion (which is a folder)
#   Note that if there are previous versions installed, or remains of folders from old installs
#   this script lists them both.
#   Intend to make the distinction and improve this script later.

# I prefer to parse the registry for information about Java because it contains more information (Name and a clear, readable version number)
# and we can also re-use this technique to look for other software later - Adobe Reader or whatever you like!
function Get-JavaRegistryVersion {
    Param (
        [Parameter( Mandatory = $true )]
        [string[]]$Computers,
        [Parameter( Mandatory = $true )]
        [string]$CurrentJavaVersion
    )

     $Computers | ForEach-Object {
        if (-not (Test-Connection -comp $_ -quiet)) {
            # If we can't reach the Computer, still return an object for it with all "unknown" or "-" values
            [pscustomobject][ordered]@{
                ComputerName     = $_;
                User             = "-";
                JavaName         = "-";
                JavaVersion      = "-";
                IsUpToDate       = "-";
            }
        } else {
            # If we can reach the computer, try and get the names of the logged on user(s)
            $users = (Get-WmiObject -Class win32_computersystem -Property username -ComputerName $_).username
            if ($null -eq $users) {
                # If the query fails or no user is logged in, set the value to "None"
                $users = "None"
            }

            # Open the registry on the remote machine - we need administrative permissions for this just like for accessing the C$ share in your original script
            $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', "$_")
            # Open the appropriate registry key on the remote machine
            $regSoftware1 = $reg.OpenSubKey('SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall')

            # We do the following check because the registry key we open above does not exist on 32-Bit systems - trying to open it will not cause an error but simply return nothing
            if ($regSoftware1) {
                # For all the installed software, search for Java and gather information about it (Name, Version etc)
                # If we place a variable in front of a foreach-loop like this, every output that is made in the loop will be assigned into the variable
                # this is much faster than using += every time!
                $JavaInstallations1 = foreach ($subkey in $regSoftware1.GetSubKeyNames()) {
                    # This is the registry key where 32-bit Software resides on 64-Bit systems. However, some software is weird and there may be entries for 64-bit Software here
                    # just like there's not really any guarantee software inside "Program Files (x86)" is always 32-Bit. From my experience this is not a problem with Java though.
                    $openkey = $reg.OpenSubKey("SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$subkey")
                    $displayName = $openkey.GetValue('DisplayName')
                    if ($displayName -match "Java \d+ Update \d+") {
                        # Here we create a PSCustomObject that contains all the interesting information about the Java instance we found.
                        # Since it's not being assigned to a variable or piped elsewhere, it falls out of the loop and gets put into $JavaInstallations
                        # Creating objects like this is nicer than "Write-Host"-ing the information because we can manipulate these later,
                        # for example filter them with "Where-Object { $_.User -ne "None"}" or easily export the info with "Export-CSV"
                        [pscustomobject][ordered]@{
                            ComputerName     = $_;
                            User             = $users;
                            JavaName         = $displayName;
                            JavaVersion      = $($openkey.GetValue("DisplayVersion"));
                            IsUpToDate       = $($openkey.GetValue("DisplayVersion") -match "^$CurrentJavaVersion");
                        }
                    }
                }
            }

            $regSoftware2 = $reg.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall')
            # This registry key should exist on all Windows systems but you never know, so we check anyway
            if ($regSoftware2) {
                # For all the installed software, search for Java and gather information about it (Name, Version etc)
                # If we place a variable in front of a foreach-loop like this, every output that is made in the loop will be assigned into the variable
                # this is much faster than using += every time!
                $JavaInstallations2 = foreach ($subkey in $regSoftware2.GetSubKeyNames()) {
                    # This is the registry key where 32-bit Software resides on 64-Bit systems. However, some software is weird and there may be entries for 64-bit Software here
                    # just like there's not really any guarantee software inside "Program Files (x86)" is always 32-Bit. From my experience this is not a problem with Java though.
                    $openkey = $reg.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$subkey")
                    $displayName = $openkey.GetValue('DisplayName')
                    if ($displayName -match "Java \d+ Update \d+") {
                        # Here we create a PSCustomObject that contains all the interesting information about the Java instance we found.
                        # Since it's not being assigned to a variable or piped elsewhere, it falls out of the loop and gets put into $JavaInstallations
                        # Creating objects like this is nicer than "Write-Host"-ing the information because we can manipulate these later,
                        # for example filter them with "Where-Object { $_.User -ne "None"}" or easily export the info with "Export-CSV"
                        [pscustomobject][ordered]@{
                            ComputerName     = $_;
                            User             = $users;
                            JavaName         = $displayName;
                            JavaVersion      = $($openkey.GetValue("DisplayVersion"));
                            IsUpToDate       = $($openkey.GetValue("DisplayVersion") -match "^$CurrentJavaVersion");
                        }
                    }
                }
            }

            return $JavaInstallations1 + $JavaInstallations2
        }
    }
}

# This will get the latest Java version from the Oracle website directly instead of having to specify it by hand
$latestJavaVersion = [regex]::Match((Invoke-WebRequest -Uri "https://java.com/en/download/windows_offline.jsp" -UseBasicParsing).RawContent, "Recommended Version (\d*) Update (\d*)")

# If the Oracle website ever changes its HTML in a way that breaks our automatic version check, or we couldn't connect to the website, ask the user for the latest version instead
if (-not $latestJavaVersion.Success) {
    Write-Error "Could not get latest Java version from Oracle website automatically!"
    do {
        $currentRegVer = Read-Host -Prompt "Please enter it manually (Format like: 8.0.192)"
        # This loop will run until the user enters the Version number in the correct format
    } until ($currentRegVer -match "\d\.0\.\d\d\d")
} else {
    $currentRegVer = "{0}.0.{1}" -f $latestJavaVersion.Groups[1].Value, $latestJavaVersion.Groups[2].Value
}

$computerNameList = Get-Content "c:\users\you\documents\computers.txt"

Get-JavaRegistryVersion -Computers $computerNameList -CurrentJavaVersion $currentRegVer
