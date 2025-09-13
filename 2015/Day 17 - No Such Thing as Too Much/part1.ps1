<#
The elves bought too much eggnog again - 150 liters this time. To fit it all
into your refrigerator, you'll need to move it into smaller containers. You take
an inventory of the capacities of the available containers.

For example, suppose you have containers of size 20, 15, 10, 5, and 5 liters. If
you need to store 25 liters, there are four ways to do it:

- 15 and 10
- 20 and 5 (the first 5)
- 20 and 5 (the second 5)
- 15, 5, and 5

Filling all containers entirely, how many different combinations of containers
can exactly fit all 150 liters of eggnog?
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
    [PSCustomObject]@{
        Perm = $_.Combination
        Sum = $_.Combination |
            Measure-Object -Sum |
            Select-Object -ExpandProperty Sum
    }
} | Where-Object {$_.Sum -eq $eggNogAmount} |
    Measure-Object |
    Select-Object -ExpandProperty Count