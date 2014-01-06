<#
.Synopsis
   Return an array of IP Addresses
.DESCRIPTION
   Return an array of System.Net.IPAddress objects from a string in the form 10.10.10.0/24.
.EXAMPLE
   Return an array of usable IP addresses given a subnet.

   PS C:\> $IPs = Get-NetworkHostList 192.168.7.0/24
   PS C:\> $IPs[0].IPAddressToString  
   192.168.7.1
   PS C:\temp> $ips[-1].IPAddressToString
   192.168.7.254
.EXAMPLE
   Return an array of IP addresses given a subnet including Network and Broadcast addresses.

   PS C:\temp> $IPs = Get-NetworkHostList 10.1.2.3/16 -All
   PS C:\temp> $ips[0].IPAddressToString
   10.1.0.0
   PS C:\temp> $ips[-1].IPAddressToString
   10.1.255.255
#>
function Get-NetworkHostList
{
    [CmdletBinding()]
    [OutputType([IPAddress[]])]
    Param
    (
        # Description of a subnet in the form 10.10.10.0/24.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidatePattern("^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/([1-3]?[0-9])$")]
        [String]
        $Network,

        # Include the Network and Broadcast Address in the results.
        [Parameter()]
        [Switch]
        $All
    )   

    End
    {
        $parts = $Network -split '/'
        $ipAddressString = $parts[0]
        $networkBits = $parts[1]

        $ip = [IPAddress]$ipAddressString
        $mask = -bNot ([uint32]::MaxValue -shR $networkBits)

        $maskBytes = [BitConverter]::GetBytes($mask)
        [Array]::Reverse($maskBytes)

        $ipBytes = $ip.GetAddressBytes()

        $startIPBytes = New-Object byte[] $ipBytes.Length
        $endIPBytes = New-Object byte[] $ipBytes.Length

        for ($i = 0; $i -lt $ipBytes.Length; $i++)
        {
            $startIPBytes[$i] = $ipBytes[$i] -bAnd $maskBytes[$i]
    
            $octet = -bNot [byte]$maskBytes[$i]
            $octetBytes = [BitConverter]::GetBytes($octet)[0]
            $endIPBytes[$i] = $ipBytes[$i] -bOr $octetBytes
        }

        $startIP = [IPAddress]$startIPBytes
        $endIP = [IPAddress]$endIPBytes

        $nextIp = $startIP

        if ($PSBoundParameters["All"])
        {
            Write-Output $startIP            
        }
        
        # First IP is Network Address
        $nextIP = Increment $nextIp

        While ($nextIp -ne $endIP)
        {
            Write-Output $nextIp
            $nextIP = Increment $nextIp
            
        }

        # Last IP is Broadcast Address
        if ($PSBoundParameters["All"])
        {
            Write-Output $nextIp
        }
    }

    Begin
    {
        Function Increment ([IPAddress]$address)
        {
            $bytes = $address.GetAddressBytes()

            for($k = $bytes.Length - 1; $k -ge 0; $k--)
            {
                $value = [BitConverter]::GetBytes($bytes[$k])[0]

                if( $value -eq ([byte]::MaxValue) )
                {
                    $bytes[$k] = 0
                    continue
                }

                $bytes[$k]++

                return [IPAddress]$bytes
            }
        }
    }
}