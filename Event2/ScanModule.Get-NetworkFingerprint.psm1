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
                        Group-Object -Property Port | 
                        Select-Object -ExpandProperty Name -Unique | 
                        ForEach-Object {$_ -as [int]} | 
                        Sort-Object

        $tcpConnections = [net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpConnections()
        $tcpConnections.Where({$_.Address -ne "127.0.0.1"})
        $remoteConnections = $tcpConnections.Where({$_.RemoteEndPoint.Address -ne "127.0.0.1"}) | 
                                Select-Object -ExpandProperty RemoteEndPoint |                                 
                                ForEach-Object {[ipaddress]$_.Address} |
                                Sort-Object Address |
                                Select-Object -ExpandProperty IPAddressToString

        Write-Output $openPorts
        <#
        [pscustomobject]@{OpenPorts = $openPorts
                          RemoteConnections = $remoteConnections} |
                        Write-Output
        #>
    }
}

Export-ModuleMember -Function Get-NetworkFingerprint