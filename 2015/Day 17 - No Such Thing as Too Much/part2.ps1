<#
While playing with all the containers in the kitchen, another load of eggnog
arrives! The shipping and receiving department is requesting as many containers
as you can spare.

Find the minimum number of containers that can exactly fit all 150 liters of
eggnog. How many different ways can you fill that number of containers and still
hold exactly 150 litres?

In the example above, the minimum number of containers was two. There were three
ways to use that many containers, and so the answer there would be 3.
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt" | ForEach-Object {
    $_ -as [int]
}

$eggNogAmount = 150

# Import the combinatorics module for the `Get-Combinations`
# which generates all permutations of all combinations of a given input
# (excluding the empty set)
Import-Module "$PSScriptRoot\..\..\_modules\Combinatorics" -Force

Get-Combinations $rawInput | ForEach-Object {
    $Sum = $_.Combination |
            Measure-Object -Sum |
            Select-Object -ExpandProperty Sum
    if ($Sum -ne $eggNogAmount) {
        return
    }
    [PSCustomObject]@{
        Perm = $_.Combination
        PermLen = $_.Combination.Count
    }
} | 
    Group-Object 'PermLen' -NoElement |
    Sort-Object Name |
    Select-Object -First 1 -ExpandProperty Count