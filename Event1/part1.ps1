#requires -version 4

$delim = ', ' 
$names = "Syed, Kim, Sam, Hazem, Pilar, Terry, Amy, Greg, Pamela, Julie, David, Robert, Shai, Ann, Mason, Sharon, Plus1" -split $delim

function Initialize-RandomArray
{
    return $names | Get-Random -Count $names.Count
}
$randomArray = Initialize-RandomArray


$half = $names.Count / 2 -as [int]
$first, $second = $randomArray.Where({$_}, 'split', $half)

for ($i = 0; $i -lt $first.Count; $i++)
{ 
    $members = @($first[$i], $second[$i])
    if ([String]::IsNullOrEmpty($first[($i+1)]) -and ![string]::IsNullOrEmpty($second[($i+1)]))
    {
        $members += $second[($i+1)]
    }

    $output = [PSCustomObject]@{Team = $i+1; Members = $members}
    $output | Write-Output
}
