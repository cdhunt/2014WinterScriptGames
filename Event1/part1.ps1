#Requires -Module ArrayMgmt

Get-Names -Path namelist.txt | Initialize-RandomArray | Get-Pairs | Set-TeamBalance