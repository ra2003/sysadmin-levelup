#in progress

Get-WmiObject win32_printer -ComputerName hostname1 | Format-List name,drivername,portname
