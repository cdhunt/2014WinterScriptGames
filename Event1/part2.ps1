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

Get-Names -Path $Path | Initialize-RandomArray | Set-Primaries -Name @("David", "Kim", "Sam", "Hazem") | Get-Pairs

<#
Start results of Set-Primaries
remove Primaries > available members
Get team history !! Need persistance
split list like in Get-Pairs
foreach first
. get previous 4 team members
. available members > working list
. get random working list member > random member
. while
 . if prevous 4 -notcontain random member
   . remove random member from available members
   . return @{Members=@(first, random member}
 . else
   . remove random member from working list
. do
#>