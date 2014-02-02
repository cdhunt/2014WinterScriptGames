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
function New-ACE
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory, Position=0)]
        [Alias("User", "Group")]
        $SecurityPrincipal,

        # Param2 help description
        [Parameter(Mandatory, Position=1)]
        [ValidateSet("AppendData", "ChangePermissions", "CreateDirectories", "CreateFiles", "Delete", "DeleteSubdirectoriesAndFiles", "ExecuteFile", "FullControl", "ListDirectory", "Modify", "Read", "ReadAndExecute", "ReadAttributes", "ReadData", "ReadExtendedAttributes", "ReadPermissions", "Synchronize", "TakeOwnership", "Traverse", "Write", "WriteAttributes", "WriteData", "WriteExtendedAttributes")]
        [String[]]
        $Right
    )

    $colRights = [Security.AccessControl.FileSystemRights]($Right -join ",")

    $InheritanceFlag = [Security.AccessControl.InheritanceFlags]::None 
    $PropagationFlag = [Security.AccessControl.PropagationFlags]::None 

    $objType =[Security.AccessControl.AccessControlType]::Allow 

    $objUser = New-Object Security.Principal.NTAccount($SecurityPrincipal) 

    $objACE = New-Object Security.AccessControl.FileSystemAccessRule `
        ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 

    return $objACE
}