Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq "True"} | Select Description,Index,IPAddress,IPSubnet,DNSDomain,DNSServerSearchOrder | Format-Table
