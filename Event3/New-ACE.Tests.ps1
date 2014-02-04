#Require -Module Pester

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
    . "$here\$sut"

    Describe "New-ACE" {
        Context "Testing ACL Creation" {
            $results = New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'Read','Write' -Inheritance ContainerInherit -Propagation InheritOnly

            It "IdentityReference should be 'BUILTIN\Administrators'" {                
                $results.IdentityReference | should be 'BUILTIN\Administrators'
            }

            It "AccessControlType should be 'Allow'" {
                $results.AccessControlType | should be 'Allow'
            }

            It "FileSystemRights should match 'Read'" {
                $results.FileSystemRights | should match 'Read'
            }

            It "FileSystemRights should match 'Write'" {
                $results.FileSystemRights | should match 'Write'
            }

            It "Inheritance should match ContainerInherit" {
                $results.InheritanceFlags | should match 'ContainerInherit'
            }

            It "Propagation should match InheritOnly" {
                $results.PropagationFlags | should match  'InheritOnly'
            }
        }
        Context "Parameter Validation" {
            It "Should not validate with bad SecurityPrincipal" {
                { New-ACE -SecurityPrincipal 'Administrators' -Right 'Read','Write' } | Should Throw
            }
            It "Should not validate with bad Right" {
                { New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'DeleteAllTheThings'} | Should Throw
            }
            It "Should not validate with bad Inheritance" {
                { New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'Read','Write' -Inheritance Invaild } | Should Throw
            }
            It "Should not validate with bad Propagation" {
                { New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'Read','Write' -Propagation NoGood } | Should Throw
            }
        }
    }
