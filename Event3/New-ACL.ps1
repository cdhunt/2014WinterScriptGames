function New-ACL {
    $colRights = [System.Security.AccessControl.FileSystemRights]"FullControl" 

    $InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::None 
    $PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None 

    $objType =[System.Security.AccessControl.AccessControlType]::Allow 

    $objUser = New-Object System.Security.Principal.NTAccount('BUILTIN\Administrators') 

    $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
        ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 

#    $objACL = Get-ACL "C:\Scripts\Test.ps1" 
#    $objACL.AddAccessRule($objACE) 

    return $objACE
}
