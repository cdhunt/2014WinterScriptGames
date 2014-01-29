<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Invoke-Scans
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter(Position=0)]
        [ValidateNotNullOrEmpty()]
        $Path,

        # Param2 help description
        [Parameter(ParameterSetName='Parameter Set 1')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [ValidateScript({$true})]
        [ValidateRange(0,5)]
        [int]
        $Param2,

        # Param3 help description
        [Parameter(ParameterSetName='Another Parameter Set')]
        [ValidatePattern("[a-z]*")]
        [ValidateLength(0,15)]
        [String]
        $Param3
    )

    Begin
    {
    }
    Process
    {
    }
    End
    {
        $scanModuleScripts = Get-ChildItem -Path $path -Filter "ScanModule*.psm1"
        foreach ($script in $scanModuleScripts)
        {
            Write-Verbose "Loading module $($script.BaseName)"
            Import-Module $script.FullName
        }

        $scanModules = Get-Module | Where-Object Name -Match "ScanModule"
        
        $scanModuleFunctions = $scanModules | Select-Object @{Label="Command"; Expression = {$_.ExportedCommands.Keys.GetEnumerator()}}

        foreach ($function in $scanModuleFunctions)
        {
            Write-Verbose "Executing $($function.Command)"
            $devnul = [scriptblock]::Create($function.Command).Invoke()
            Write-Output $devnul
        }

    }
}
