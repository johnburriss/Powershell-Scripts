$Computer = Read-host -Prompt "Enter the FQDN of Host"
$file = $computer.split(".")[0] 

$user = Get-WmiObject –ComputerName $computer –Class Win32_ComputerSystem | Select -ExpandProperty UserName

Invoke-GPUpdate -Computer "$Computer" -Force

Start-Sleep -s 10

Get-GPResultantSetOfPolicy -ReportType html -Computer $Computer -User "$user" -Path "c:\temp\$file.html"

Invoke-Item "c:\temp\$file.html"
