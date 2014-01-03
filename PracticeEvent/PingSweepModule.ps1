Import-Module C:\Users\chunt\Documents\GitHub\2014WinterScriptGames\PracticeEvent\IPModule.psm1
$Credential = Get-Credential
$ips = Get-NetworkHostList 10.81.60.0/24
$list = $ips[(2..6)]

$c = 0
Foreach ($computer in $list)
{
    [bool]$alive = $false
    Write-Progress -Activity "Finding available hosts" -Status "Testing" -CurrentOperation $computer -PercentComplete (($c++/$list.count)*100)

    $pingResults = Test-Connection -ComputerName $computer -Count 2

    if (($pingResults | Select-Object -ExpandProperty StatusCode) -contains 0)
    {
        $alive = $true
    }
    if ($alive)
    {
        $computerName = [Net.Dns]::GetHostEntry($computer)
        Write-Output $computerName
        Get-WmiObject -Namespace 'root\CIMV2' -Class 'Win32_OperatingSystem' -ComputerName $computerName.HostName -Credential $Credential -Impersonation Impersonate -Authentication PacketPrivacy 
    }
}
