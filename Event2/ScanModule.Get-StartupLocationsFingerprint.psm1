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
function Get-StartupLocationsFingerprint
{
    [CmdletBinding()]
    [OutputType([PSObject[]])]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline, Position=0)]
        $InputObject
    )

    Begin
    {
        $items = @()
    }
    Process
    {
        if ($PSBoundParameters["InputObject"])
        {
            Foreach ($object in $InputObject)
            {
                $items += $object
            }
        }
        else
        {
            $modulePath = Get-Module -Name ExecutionEngine | Select-Object -ExpandProperty Path | Split-Path -Parent
            $items = Get-Content -Path (Join-Path -Path $modulePath -ChildPath "ScanModule.Get-StartupLocationsFingerprint.config")
        }
    }
    End
    {
        foreach ($item in $items)
        {
            Get-ChildItem -Path $item -ErrorAction SilentlyContinue | 
                Select-Object -Property Name |
                Write-Output
        }
    }
}

Export-ModuleMember -Function Get-StartupLocationsFingerprint