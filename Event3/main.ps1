. .\Event3\Compare-ACE.ps1                                                                                                                                                                                                                                                    
. .\Event3\New-ACE.ps1
$fileACL = Get-Acl C:\temp\ScriptgamesTemp

# TODO: BUild a list of GOOD ACEs
$goodACL = ,(New-ACE -SecurityPrincipal "builtin\administrators" -Right FullControl -ControlType Allow )

$good = @()
$bad = @()

$c = $goodACL.Count

$missing = ,$true * $c

# Step through each ACE on an object
foreach ($objectAccess in $fileACL.Access)
{

    for( $i=0; $i -lt $c; $i++)
    {

        $result = Compare-ACE $goodACL[$i] $objectAccess

        if ($result)
        {
            $missing[$i] = $false
            $good += $objectAccess
        }
        else
        {
            $bad += $objectAccess
        }
    }
}
