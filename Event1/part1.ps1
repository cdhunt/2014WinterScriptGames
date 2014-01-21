#requires -version 4

$delim = ', ' 
$names = "Syed, Kim, Sam, Hazem, Pilar, Terry, Amy, Greg, Pamela, Julie, David, Robert, Shai, Ann, Mason, Sharon" -split $delim

function Initialize-RandomArray
{
    return $names | Get-Random -Count $names.Count
}
$randomArray = Initialize-RandomArray


function Get-NamePairs
    {
    $half = $names.Count / 2 -as [int]
    $first, $second = $randomArray.Where({$_}, 'split', $half)

    for ($i = 0; $i -lt $second.Count; $i++)
    { 
        $members = @($first[$i], $second[$i])


        $output = [PSCustomObject]@{Team = $i+1; Members = $members}
        $output | Write-Output
    }
}

$teams = Get-NamePairs

function Set-TeamBalance
{
    $lastTeamIndex = $teams.Count - 1
    foreach ($team in $teams)
    {
        if ($team.Members -contains $null)
        {
            $lastTeamIndex--
            $loner = $team | Where-Object {$_.Members -contains $null} | Select-Object -ExpandProperty Members
            $allNames = $teams | Where-Object {$_.Members -notcontains $null} | Select-Object -ExpandProperty Members
         
            $prompt = "Who's team would you like to add $loner?"
            Write-Host "Available members"
            Write-Host ($allNames -join $delim)
            $specialTeam = Read-Host -Prompt $prompt
        }
    }

    foreach ($team in $teams)
    {
        if ($team.Members -contains $specialTeam)
        {
            Write-Host "Found it"
            $team.Members += $loner
        }
    }

    $teams[(0..$lastTeamIndex)] | Write-Output
}

Set-TeamBalance