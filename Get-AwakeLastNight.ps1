#uniquegeek@gmail.com
#Input: run this script against selected hosts in Scripts section of SCCM
#Output: list of hostnames and whether they had events between 0:00 and 0:30 today
#  hosts that were on will have events in the middle of the night, hosts that were off will have $event -eq $null

$h = hostname
$start = Get-Date
$start = $start.AddHours(-$start.Hour)
$start = $start.AddMinutes(-$start.Minute)
$start = $start.AddSeconds(-$start.Second)
$end = $start.AddMinutes(30)

$events = Get-EventLog -LogName Security -after $start -Before $end

if ($events -ne $null) { Write-Host "$h,OnAtMidnight"} else { Write-Host "$h,Off"}
