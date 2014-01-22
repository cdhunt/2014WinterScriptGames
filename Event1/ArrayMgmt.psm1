#requires -version 4

$DELIMITER = ',' 

function Get-Names
{
    [CmdletBinding()]
    [OutputType([String[]])]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $Path
    )

    $file = (Get-Content -Path $Path) -join $DELIMITER

    $list = $file -split $DELIMITER

    foreach ($i in $list)
    {
        $i.ToString().Trim() | Write-Output
    }
}


function Initialize-RandomArray
{
    [CmdletBinding()]
    [OutputType([String[]])]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $InputObject
    )
    Begin
    {
        $list = @()
    }
    Process
    {
        $list += $InputObject        
    }
    End
    {
        return $list | Get-Random -Count $list.Count
    }
}

function Get-Pairs
{
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $InputObject
    )
    Begin
    {
        $list = @()
    }
        Process
    {
        $list += $InputObject        
    }
    End
    {
        $half = $list.Count / 2 -as [int]
        $first, $second = $list.Where({$_}, 'split', $half)

        for ($i = 0; $i -lt $second.Count; $i++)
        { 
            $members = @($first[$i], $second[$i])

            $output = [PSCustomObject]@{Team = $i+1; Members = $members}
            $output | Write-Output
        }
    }
}

function Set-TeamBalance
{
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $InputObject
    )
    Begin
    {
        $list = @()
    }
        Process
    {
        $list += $InputObject        
    }
    End
    {
        $lastTeamIndex = $list.Count - 1
        foreach ($team in $list)
        {
            if ($team.Members -contains $null)
            {
                $lastTeamIndex--
                $loner = $team | Where-Object {$_.Members -contains $null} | Select-Object -ExpandProperty Members
                $allNames = $list | Where-Object {$_.Members -notcontains $null} | Select-Object -ExpandProperty Members
         
                $prompt = "To who's team would you like to add $($loner)?"
                Write-Host "Available members:" ($allNames -join $DELIMITER)

                $specialTeam = Read-Host -Prompt $prompt
            }
        }

        foreach ($team in $list)
        {
            if ($team.Members -contains $specialTeam)
            {
                $team.Members += $loner
            }
        }

        $list[(0..$lastTeamIndex)] | Write-Output
    }
}


Export-ModuleMember -Function * -Variable DELIMITER