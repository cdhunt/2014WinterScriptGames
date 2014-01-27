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
function Invoke-Scan
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [PSObject[]]
        $InputObject,

        # Param2 help description
        [Parameter(Mandatory=$true, Position=1)]
        [scriptblock]
        $Filter
    )

    Begin
    {
        $processItems = @()
        $results = @()
    }
    Process
    {
        foreach ($object in $InputObject)
        {
            $processItems += $object
        }
    }
    End
    {
        foreach ($item in $processItems)
        {
           $results += & $Filter

        }

        Write-Output $results

    }
}

$filterScript = [scriptblock]{if ($item -match "windir")
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
                                 "hash" = $file.MD5Hash
                                 "timestamp" = $file.LastWriteTime
                                 "length" = $file.Length}

        Write-Output $obj

    }  
    catch
    {
        Write-Verbose "Cannot generate hash of $item"
    }
}

Get-Content "C:\Users\chunt\Documents\GitHub\2014WinterScriptGames\Event2\DataSystemFiles.nfo" | Invoke-Scan -Filter $filterScript