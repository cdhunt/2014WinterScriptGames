$here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
    . "$here\$sut"

    Describe "Compare-ACE" {
        Context "Test Compare-ACE" {
            . "$here\New-Ace.ps1"

            $ace_same1 = New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'Read','Write' -Inheritance ContainerInherit -Propagation InheritOnly
            $ace_same2 = New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'Read','Write' -Inheritance ContainerInherit -Propagation InheritOnly
            $ace_dif = New-ACE -SecurityPrincipal 'BUILTIN\users' -Right 'Read'
            
            It "Test similar" {
                $results = Compare-ACE $ace_same1 $ace_same2
                $results | should be $true
            }
            It "Test disimilar" {
                $results = Compare-ACE $ace_same1 $ace_dif
                $results | should be $false
            }
        }
    }
