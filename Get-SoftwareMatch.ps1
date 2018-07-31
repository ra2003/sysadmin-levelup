#in progress

Get-WmiObject -class win32_product -computer hostname1 | Where-Object -FilterScript{$_.Name -like "*adobe*"} | Format-Table IdentifyingNumber,Name,Version,localpackage
