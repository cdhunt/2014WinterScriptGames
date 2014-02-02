<#
.Synopsis
   Create a new Access Control Entry.
.DESCRIPTION
   Create a new Access Control Entry for each provided SecurityPrincipal with the provided parameters.
.EXAMPLE
   PS C:\> New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'FullControl'

   
   FileSystemRights  : FullControl
   AccessControlType : Allow
   IdentityReference : BUILTIN\Administrators
   IsInherited       : False
   InheritanceFlags  : None
   PropagationFlags  : None
.EXAMPLE
   PS C:\> New-ACE -SecurityPrincipal 'BUILTIN\users' -Right 'Read', 'Write' -ControlType Deny


   FileSystemRights  : Write, Read, Synchronize
   AccessControlType : Deny
   IdentityReference : BUILTIN\users
   IsInherited       : False
   InheritanceFlags  : None
   PropagationFlags  : None
#>
function New-ACE
{
    [CmdletBinding()]
    [OutputType([Security.AccessControl.FileSystemAccessRule])]
    Param
    (
        # User or Group name in the form of Domain\Object
        [Parameter(Mandatory, Position=0)]
        [Alias("User", "Group", "IdentityReference")]
        [ValidatePattern(".+\\.+")]
        [string[]]
        $SecurityPrincipal,

        # Rights to attach to this Access Control Entry
        [Parameter(Mandatory, Position=1)]
        [ValidateSet("AppendData", "ChangePermissions", "CreateDirectories", "CreateFiles", "Delete", "DeleteSubdirectoriesAndFiles", "ExecuteFile", "FullControl", "ListDirectory", "Modify", "Read", "ReadAndExecute", "ReadAttributes", "ReadData", "ReadExtendedAttributes", "ReadPermissions", "Synchronize", "TakeOwnership", "Traverse", "Write", "WriteAttributes", "WriteData", "WriteExtendedAttributes")]
        [String[]]
        $Right,

        # Allow or Deny
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
        $objUser = New-Object Security.Principal.NTAccount($sp) 

        $colRights = @()
        foreach ($r in $Right)
        {            
            
            $colRights += [Security.AccessControl.FileSystemRights]$r
            
        }

        $objACE = New-Object Security.AccessControl.FileSystemAccessRule `
                ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 

        Write-Output $objACE
    }
}