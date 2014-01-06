Import-Module C:\Users\chunt\Documents\GitHub\2014WinterScriptGames\PracticeEvent\IPModule.psm1
$Credential = Get-Credential
$ips = Get-NetworkHostList 10.81.60.0/24
$list = $ips[(70..75)]

$c = 0
Foreach ($computer in $list)
{
    [bool]$alive = $false
    Write-Progress -Activity "Finding available hosts" -Status "Testing" -CurrentOperation $computer -PercentComplete (($c++/$list.count)*100)

    try {
        $pingResults = Test-Connection -ComputerName $computer -Count 2 -ErrorAction SilentlyContinue
    }
    catch
    {
        # Supress Error Message, but we want full results so don't use -Quiet
    }

    if (($pingResults | Select-Object -ExpandProperty StatusCode) -contains 0)
    {
        $alive = $true
    }
    if ($alive)
    {
        $computerName = [Net.Dns]::GetHostEntry($computer)
        Write-Output $computerName.HostName

        <# TODO: Handle local host connection (no credentials)
Get-WmiObject : User credentials cannot be used for local connections At C:\...\PingSweepModule.ps1:22 char:9
+         Get-WmiObject -Namespace 'root\CIMV2' -Class 'Win32_OperatingSystem' -Co ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [Get-WmiObject], ManagementException
    + FullyQualifiedErrorId : GetWMIManagementException,Microsoft.PowerShell.Commands.Get
   WmiObjectCommand
        #>
        try
        {
            Get-WmiObject -Namespace 'root\CIMV2' -Class 'Win32_OperatingSystem' -ComputerName $computerName.HostName -Credential $Credential -Impersonation Impersonate -Authentication PacketPrivacy -ErrorAction Stop
        }
        catch [System.Management.ManagementException]
        {
            $thisError = $_
            if ($thisError.Exception.ErrorCode -eq [System.Management.ManagementStatus]::LocalCredentials)
            {
                try
                {
                    Get-WmiObject -Namespace 'root\CIMV2' -Class 'Win32_OperatingSystem' -ComputerName $computerName.HostName -ErrorAction Stop
                }
                catch
                {
                    Write-Warning "Could not access WMI on $($computerName.HostName)."
                }
            }
            else
            {
                Write-Warning "Invalid Operation Exception connection to $($computerName.HostName). Status: $($thisError.Exception.ErrorCode.ToString())"
            }
        }
        catch [System.UnauthorizedAccessException]
        {
            Write-Warning "Access denied to $($computerName.HostName) with username $($Credential.UserName)"
        }
        catch
        {
            Write-Warning "Could not connect to $($computerName.HostName)"
        }

    }
}
