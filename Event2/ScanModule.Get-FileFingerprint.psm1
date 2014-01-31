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
function Get-FileFingerprint
{
    [CmdletBinding()]
    [OutputType([PSObject[]])]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline,Position=0)]
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
            $items = Get-Content -Path (Join-Path -Path $modulePath -ChildPath "ScanModule.Get-FileFingerprint.config")
        }
    }
    End
    {
        foreach ($item in $items)
        {
            if ($item -match "windir")
            {
                $expandedPath = $item  -replace "windir", $env:windir
            }
            else
            {
                $expandedPath = $item
            }

            try
            {

                $file = Get-Item -Path $expandedPath -ErrorAction Stop

                $obj = [pscustomobject]@{"path" = $file.FullName
                                         "hash" = (Get-FileHash $file -Algorithm MD5 | Select-Object -ExpandProperty Hash)
                                         "timestamp" = $file.LastWriteTime
                                         "length" = $file.Length}

                Write-Output $obj

            }  
            catch
            {
                Write-Verbose "Cannot generate hash of $item"
            }
        }
    }
}

Export-ModuleMember -Function Get-FileFingerprint