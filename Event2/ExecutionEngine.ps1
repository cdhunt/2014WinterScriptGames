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

        # A Scriptblock that processes each object in InputObject
        [Parameter(Mandatory=$true, Position=1)]
        [scriptblock]
        $Fingerprint
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
           $results += & $Fingerprint

        }

        Write-Output $results

    }
}

$FileFingerprint = [scriptblock]{
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

$EnvironmentVarsFingerprint = [scriptblock]{
    [pscustomobject]@{"Name" = $item.Name.ToString(); "Value" = $item.Value.ToString()} | Write-Output
 }

$NetworkFingerpring = [scriptblock]{
    $pattern = [regex]"(\S+)\s+(\S+):(\S+)\s+(\S*):(\S+)\s*(\S*)"
    
    $matches = $pattern.Match($item)

    $proto = [string]::Empty
    $localAddr = [string]::Empty
    $localPort = [string]::Empty
    $foreignAddr = [string]::Empty
    $foreignPort = [string]::Empty
    $state = [string]::Empty

    switch ($matches.Groups.Count)
    {   
        {$_-gt 6} {$state = $matches.Groups[6].Value}     
        {$_-gt 5} {$foreignPort = $matches.Groups[5].Value}
        {$_-gt 4} {$foreignAddr = $matches.Groups[4].Value}
        {$_-gt 3} {$localPort = $matches.Groups[3].Value}
        {$_-gt 2} {$localAddr = $matches.Groups[2].Value}
        {$_-gt 1} {$proto = $matches.Groups[1].Value}
    }

    $obj = [pscustomobject]@{"Proto" = $proto
                      "LocalAddress" = $localAddr
                      "LocalPort" = $localPort
                      "ForeignAddress" = $foreignAddr
                      "ForeignPort" = $foreignPort
                      "State" = $state}

    Write-Output $obj
}

$StartupLocationsFingerprint = [scriptblock]{
    $obj = Get-ChildItem -Path $item -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
    Write-Output $obj
}

Get-Content "C:\Users\chunt\Documents\GitHub\2014WinterScriptGames\Event2\DataSystemFiles.nfo" | Invoke-Scan -Fingerprint $FileFingerprint
#Get-ChildItem "env:\" | Invoke-Scan -Fingerprint $EnvironmentVarsFingerprint
#Netstat -a | Select-Object -Skip 5 | Invoke-Scan -Fingerprint $NetworkFingerpring
#Get-Content "C:\Users\chunt\Documents\GitHub\2014WinterScriptGames\Event2\DataStarupLocations.nfo" | Invoke-Scan -Fingerprint $StartupLocationsFingerprint