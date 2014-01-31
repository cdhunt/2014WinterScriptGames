<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-NetworkFingerprint
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (

    )

    End
    {
        $tcpListeners = [net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners()

        $openPorts = $tcpListeners | 
                        Select-Object -Expand Port -Unique | 
                        ForEach-Object {$_ -as [int]} | 
                        Sort-Object |
                        Select-Object @{Label="Port"; Expression={$_}} |
                        Write-Output

        <#
        $tcpConnections = [net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpConnections()

        $remoteConnections = $tcpConnections.Where({$_.RemoteEndPoint.Address -ne "127.0.0.1"}) | 
                                Select-Object -ExpandProperty RemoteEndPoint |                                 
                                ForEach-Object {[ipaddress]$_.Address} |
                                Sort-Object Address |
                                Select-Object -Property @{Label="Address"; Expression={$_.IPAddressToString}}


        }
        
        [pscustomobject]@{OpenPorts = $openPorts
                          RemoteConnections = $remoteConnections} |
                        Write-Output
        #>
    }
}

Export-ModuleMember -Function Get-NetworkFingerprint