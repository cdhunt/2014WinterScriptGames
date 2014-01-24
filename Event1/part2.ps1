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