$here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
    . "$here\$sut"

    Describe "Compare-ACE" {
        Context "Test Compare-ACE" {
            . "$here\New-Ace.ps1"

            $ace_same = New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'Read','Write' -Inheritance ContainerInherit -Propagation InheritOnly
            
            
            It "Test similar" {
                $results = Compare-ACE $ace_same $ace_same
                $results | should be $true
            }
            It "Test dissimilar user" {
                $ace_dif = New-ACE -SecurityPrincipal 'BUILTIN\users' -Right 'Read','Write' -Inheritance ContainerInherit -Propagation InheritOnly

                $results = Compare-ACE $ace_same $ace_dif
                $results | should be $false
            }
            It "Test dissimilar Rights" {
                $ace_dif = New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'Read' -Inheritance ContainerInherit -Propagation InheritOnly

                $results = Compare-ACE $ace_same $ace_dif
                $results | should be $false
            }
            It "Test dissimilar Inheritance" {
                $ace_dif = New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'Read','Write' -Propagation InheritOnly

                $results = Compare-ACE $ace_same $ace_dif
                $results | should be $false
            }
            It "Test dissimilar Propagation" {
                $ace_dif = New-ACE -SecurityPrincipal 'BUILTIN\Administrators' -Right 'Read','Write'  -Inheritance ContainerInherit 

                $results = Compare-ACE $ace_same $ace_dif
                $results | should be $false
            }
        }
    }
