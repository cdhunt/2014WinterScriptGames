#Requires -Module ArrayMgmt
Param
(
	[ValidateScript({Test-Path -Path $_})]
	[string]
	$Path = "namelist.txt"
)

$teams = Get-Names -Path $Path | Initialize-RandomArray | Get-Pairs -reassignsinglton #| Set-TeamBalance

foreach ($team in $teams) 
{
	$team.Members -join ($DELIMITER + ' ')
}