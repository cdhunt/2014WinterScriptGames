. .\Event3\Compare-ACE.ps1                                                                                                                                                                                                                                                    
. .\Event3\New-ACE.ps1
$fileACL = Get-Acl C:\temp\ScriptgamesTemp

# TODO: BUild a list of GOOD ACEs
$goodACL = ,(New-ACE -SecurityPrincipal "builtin\administrators" -Right FullControl -ControlType Allow )

$good = @()
$bad = @()
$missing = @()

# Step through each ACE on an object
foreach ($objectAccess in $fileACL.Access)
{

    foreach ($acl in $goodACL)
    {
        # TODO: If goodACL doesn't match any existing, keep track of it to add it.
        #$missing = $true

        $result = Compare-ACE $acl $objectAccess

        if ($result)
        {
            $missing = $false
            $good += $objectAccess
        }
        else
        {
            $bad += $objectAccess
        }

        #if ($missing)
        #{
        #    $missing += $acl
        #}
    }
}
