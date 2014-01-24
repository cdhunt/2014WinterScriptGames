#Requires -Module ArrayMgmt

$Path = "C:\Users\chunt\Documents\GitHub\2014WinterScriptGames\Event1\namelist.txt"

function Set-Primaries
{
    [CmdletBinding()]
    [OutputType([String[]])]
    Param
    (
		# Specifies objects to send to the cmdlet through the pipeline. This parameter enables you to pipe objects to Initialize-RandomArray.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $InputObject,
		
		[Parameter(Mandatory)]
		[String[]]
		$Name
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
        $newList = $Name + @($list | ?{$Name -notcontains $_})
		
		Write-Output $newList
    }
}

$weekNo = Get-Date -UFormat %V
$year = Get-Date -Format "yyyy"
$fileName = "teamlist{0}_{1}.xml" -f $year, $weekNo
$primaries = @("David", "Kim", "Sam", "Hazem")

# Start results of Set-Primaries
$orderedList = Get-Names -Path $Path | Initialize-RandomArray | Set-Primaries -Name $primaries #| Get-Pairs | Export-Clixml -Path $fileName

# remove Primaries > available members
$availableMembers = $orderedList.Where({$primaries -notcontains $_})

# Get team history !! Need persistance
$groupHistory = @()
foreach ($file in (dir -Filter "teamlist*.xml" | sort LastWriteTime -Descending | select -First 4))
{
	$groupHistory += Import-Clixml $file
}

# split list like in Get-Pairs
$half = $orderedList.Count / 2 -as [int]
$first, $second = $orderedList.Where({$_}, 'split', $half)

# foreach first
foreach ($f in $first)
{
	# get previous 4 team members
	$teamhistory = $groupHistory | select Members | ? Members -contains "David" | select -ExpandProperty Members -Unique
	
	# available members > working list
	$workingList = @()
	$second.CopyTo($workingList, ($workingList.Count-1)) 
	
	# get random working list member > random member
	$randomMember = $workingList | Get-Random -Count 1
	
	# i = 0; c = working list count
	$i = 0
	$c = $workingList.Count
	$s = [string]::Empty
	while ($i++ -lt $c)
	{
		# if prevous 4 -notcontain random member
		if ($teamhistory -notcontains $randomMember)
		{
			# remove random member from available members
			$second.Remove($randomMember) | Out-Null
			$s = $randomMember
			$i = $c
		}
		else
		{
			# remove random member from working list and look around to get new random member
			$workingList.Remove($randomMember) | Out-Null
		}
	}
	
	if ([string]::IsNullOrEmpty($s))
	{
		throw "no suitable match for $f was found"
	}
	
	Write-Output @($f, $s)
}
