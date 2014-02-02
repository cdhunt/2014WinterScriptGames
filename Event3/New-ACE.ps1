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
    [OutputType([Security.AccessControl.FileSystemAccessRule])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory, Position=0)]
        [Alias("User", "Group")]
        [string[]]
        $SecurityPrincipal,

        # Param2 help description
        [Parameter(Mandatory, Position=1)]
        [ValidateSet("AppendData", "ChangePermissions", "CreateDirectories", "CreateFiles", "Delete", "DeleteSubdirectoriesAndFiles", "ExecuteFile", "FullControl", "ListDirectory", "Modify", "Read", "ReadAndExecute", "ReadAttributes", "ReadData", "ReadExtendedAttributes", "ReadPermissions", "Synchronize", "TakeOwnership", "Traverse", "Write", "WriteAttributes", "WriteData", "WriteExtendedAttributes")]
        [String[]]
        $Right,

        [Parameter(Position=3)]
        [ValidateSet("Allow", "Deny")]
        [String]
        $ControlType = 'Allow'
    )

    $InheritanceFlag = [Security.AccessControl.InheritanceFlags]::None 
    $PropagationFlag = [Security.AccessControl.PropagationFlags]::None

    $objType = [Security.AccessControl.AccessControlType]$ControlType
    
    foreach ($sp in $SecurityPrincipal)
    {
        foreach ($r in $Right)
        {            
            $objUser = New-Object Security.Principal.NTAccount($sp) 
            $colRights = [Security.AccessControl.FileSystemRights]$r

            $objACE = New-Object Security.AccessControl.FileSystemAccessRule `
                ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 

                Write-Output $objACE
        }
    }
}