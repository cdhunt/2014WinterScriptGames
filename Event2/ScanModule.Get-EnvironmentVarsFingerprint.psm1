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
function Get-EnvironmentVarsFingerprint
{
    [CmdletBinding()]
    [OutputType([PSObject[]])]
    Param
    (

    )

    End
    {
        $items = Get-ChildItem "env:\"

        Foreach ($item in $items)
        {
            [pscustomobject]@{"Name" = $item.Name.ToString()
                              "Value" = $item.Value.ToString()} | 
                              Write-Output
        }
    }
}

Export-ModuleMember -Function Get-EnvironmentVarsFingerprint