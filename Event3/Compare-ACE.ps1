<#
.Synopsis
   Compare two Access Control Entries
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Compare-ACE
{
    [CmdletBinding()]
    [OutputType([bool])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory, Position=0)]
        [Security.AccessControl.FileSystemAccessRule]
        $ReferenceObject,

        # Param2 help description
        [Parameter(Mandatory, Position=2)]
        [Security.AccessControl.FileSystemAccessRule]
        $DifferenceObject
    )

    $comparison = Compare-Object -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject -Property FileSystemRights, AccessControlType, IdentityReference, InheritanceFlags, PropagationFlags

    if ($comparison)
    {
        Write-Output $false
    }
    else
    {
        Write-Output $true
    }
}