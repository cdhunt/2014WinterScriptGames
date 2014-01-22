#requires -version 4

$DELIMITER = ',' 

function Get-Names
{
    [CmdletBinding()]
    [OutputType([String[]])]
    Param
    (
		# Path to a file containing a name list.
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
		# Specifies objects to send to the cmdlet through the pipeline. This parameter enables you to pipe objects to Initialize-RandomArray.
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
		# Specifies objects to send to the cmdlet through the pipeline. This parameter enables you to pipe objects to Get-Pairs.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $InputObject,
		
		# Assign the last person in an odd numbered list to a selected team. Default is True.
		[Parameter(Mandatory=$false)]
		[Switch]
		$ReassignSinglton = $true
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

		$teams = @()
        for ($i = 0; $i -lt $second.Count; $i++)
        { 
            $members = @($first[$i], $second[$i])

            $teams += [PSCustomObject]@{Team = $i+1; Members = $members}
        }
		
		$lastTeamIndex = $teams.Count - 1
		
		if ($ReassignSinglton -eq $true)
		{			
	        foreach ($team in $teams)
	        {
	            if ($team.Members -contains $null)
	            {
	                $lastTeamIndex--
	                $loner = $team | Where-Object {$_.Members -contains $null} | Select-Object -ExpandProperty Members	            
	         
	                $prompt = "To who's team would you like to add $($loner)?"
	                Write-Host "Available members:" ($first -join ($DELIMITER + ' '))

	                $specialTeam = Read-Host -Prompt $prompt
	            }
	        }

	        foreach ($team in $teams)
	        {
	            if ($team.Members -contains $specialTeam)
	            {
	                $team.Members += $loner
	            }
	        }
		}

        $teams[(0..$lastTeamIndex)] | Write-Output
    }		
}

Export-ModuleMember -Function * -Variable DELIMITER