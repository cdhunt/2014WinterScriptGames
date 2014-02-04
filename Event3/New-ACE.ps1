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
        [ValidateScript({
            if ($_ -match ".+\\.+") {$true} else 
            {Throw "Please provide the SecurityPricipal in the form of Domain\Object."}
        })]
        [string[]]
        $SecurityPrincipal,

        # Rights to attach to this Access Control Entry
        [Parameter(Mandatory, Position=1)]
        [Security.AccessControl.FileSystemRights]
        $Right,

        # Allow or Deny
        [Parameter(Position=2)]
        [Security.AccessControl.AccessControlType]
        $ControlType = 'Allow',

        # Inheritance Flag
        [Parameter(Position=3)]
        [Security.AccessControl.InheritanceFlags]
        $Inheritance = 'None',

        # Propagation Flag
        [Parameter(Position=4)]
        [Security.AccessControl.PropagationFlags]
        $Propagation = 'None'
    )
   
    foreach ($sp in $SecurityPrincipal)
    {
        $user = New-Object Security.Principal.NTAccount($sp) 

        $objACE = New-Object Security.AccessControl.FileSystemAccessRule($user, $Right, $Inheritance, $Propagation, $ControlType) 

        Write-Output $objACE
    }
}