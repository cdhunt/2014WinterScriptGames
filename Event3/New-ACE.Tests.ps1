$here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
    . "$here\$sut"

    Describe "New-ACE" {
        Context "Testing ACL Creation" {
            $results = New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'FullControl'

            It "Should return a new ACE object" {                
                $results | should Not BeNullOrEmpty
            }

            It "Property AccessControlType should be 'Allow' and Rights should be 'FullControl' for 'BUILTIN\Administrators'" {
                $results | Where {$_.IdentityReference -eq 'BUILTIN\Administrators' -and $_.AccessControlType -eq 'Allow' -and $_.FileSystemRights -eq 'FullControl'} | should Not BeNullOrEmpty
            }
        }
    }
