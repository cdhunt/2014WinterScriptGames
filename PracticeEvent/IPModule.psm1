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
        
        $nextIP = Increment $nextIp

        While ($nextIp -ne $endIP)
        {
            Write-Output $nextIp
            $nextIP = Increment $nextIp
            
        }

        if ($PSBoundParameters["All"])
        {
            Write-Output $nextIp
        }
    }

    Begin
    {
        function Increment ([IPAddress]$address)
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