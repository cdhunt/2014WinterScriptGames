#Require -Module Pester

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
    . "$here\$sut"

    Describe "New-ACE" {
        Context "Testing ACL Creation" {
            $results = New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'FullControl', 'Read'

            It "Should not contain any Pricipal over than Administrator" {                
                $results.IdentityReference -notcontains 'BUILTIN\Administrators' | should not be $true
            }

            It "Property AccessControlType should be 'Allow' and Rights should be 'FullControl' for 'BUILTIN\Administrators'" {
                $results.IdentityReference -eq 'BUILTIN\Administrators' -and $results.AccessControlType -eq 'Allow' -and $results.FileSystemRights -match 'FullControl' | should be $true
            }

            It "Property AccessControlType should be 'Allow' and Rights should be 'Read' for 'BUILTIN\Administrators'" {
                $results.IdentityReference -eq 'BUILTIN\Administrators' -and $results.AccessControlType -eq 'Allow' -and $results.FileSystemRights -match 'Read' | should be $true
            }
        }
    }
