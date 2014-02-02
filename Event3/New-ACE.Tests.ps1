#Require -Module Pester

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
    . "$here\$sut"

    Describe "New-ACE" {
        Context "Testing ACL Creation" {
            $results = New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'FullControl'

            It "Should not contain any Pricipal over than Administrator" {                
                $results | Where {$_.IdentityReference -ne 'BUILTIN\Administrators'} | should BeNullOrEmpty
            }

            It "Property AccessControlType should be 'Allow' and Rights should be 'FullControl' for 'BUILTIN\Administrators'" {
                $results | Where {$_.IdentityReference -eq 'BUILTIN\Administrators' -and $_.AccessControlType -eq 'Allow' -and $_.FileSystemRights -eq 'FullControl'} | should Not BeNullOrEmpty
            }
        }
    }
