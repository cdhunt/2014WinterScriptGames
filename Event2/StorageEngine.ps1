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
function Write-ScanResults
{
    [CmdletBinding()]
    [OutputType([null])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        $InputObject,

        # Param2 help description
        [Parameter(Mandatory=$true, Position=1)]
        [string]
        $Path,

        [Parameter(Mandatory=$true, Position=2)]      
        [string]
        $ModuleName,

        [Parameter(Mandatory=$true, Position=3)]      
        [string]
        $Computer,

        [Parameter(Mandatory=$true, Position=4)]      
        [string]
        $Password,

        [Parameter(Mandatory=$true, Position=5)] 
        [ValidateSet("CSV", "JSON")]     
        [string]
        $SerializeAs,

        [Parameter(Position=5)] 
        [switch]
        $Compress = $true
    )

    $string = [string]::Empty
    $datestamp = Get-Date -Format "yyyy-MM-dd"
    $reportFileName = "$($ModuleName)_$datestamp.dat"
    $reportFolderPath = Join-Path -Path $Path -ChildPath $Computer
    $reportFullPath = Join-Path -Path reportFolderPath -ChildPath $newReportFileName

    switch ($SerializeAs)
    {
        'JSON' {$string = $InputObject | ConvertTo-Json}
        Default {$string = $InputObject -join "`n`r" | ConvertTo-Csv}
    }

    $encryptParams = @{"Password" = $Password
                       "Compress" = $Compress}
    $secureResults = Write-EncryptedString $string @encryptParams

    if (-not (Test-Path -Path $reportFolderPath -PathType Container))
    {
        New-Item -Path $Path -Name $Computer -ItemType Directory -Force
    }
    Add-Content -Path $reportFullPath -Value $secureResults -Encoding UTF8 -Force
}


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
function Read-ScanResults
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (

        [Parameter(Mandatory=$true, Position=1)]      
        [string]
        $Computer,

        [Parameter(Mandatory=$true, Position=2)]      
        [string]
        $ModuleName,

        [Parameter(Mandatory=$true, Position=3)]      
        [DateTime]
        $Date,

        [Parameter(Mandatory=$true, Position=4)]      
        [string]
        $Password,

        [Parameter(Position=5)] 
        [ValidateSet("CSV", "JSON")]     
        [string]
        $SerializeAs
    )

    $string = [string]::Empty
    $datestamp = Get-Date -Format "yyyy-MM-dd"
    $reportFileName = "$($ModuleName)_$datestamp.dat"
    $reportFolderPath = Join-Path -Path $Path -ChildPath $Computer
    $reportFullPath = Join-Path -Path reportFolderPath -ChildPath $newReportFileName

    if (Test-Path -Path $reportFullPath -PathType File)
    {
        $contents = Get-Content $reportFullPath -Raw

        $decrypted = Read-EncryptedString -InputObject $contents -Password Password

        if ($decrypted[0] -match '{')
        {
            $decrypted | ConvertFrom-Json
        }
        else
        {
            $decrypted | ConvertFrom-Csv
        }
    }

}