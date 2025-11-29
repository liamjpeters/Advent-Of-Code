<#
The crabs don't seem interested in your proposed solution. Perhaps you
misunderstand crab engineering?

As it turns out, crab submarine engines don't burn fuel at a constant rate.
Instead, each change of 1 step in horizontal position costs 1 more unit of fuel
than the last: the first step costs 1, the second step costs 2, the third step
costs 3, and so on.

As each crab moves, moving further becomes more expensive. This changes the best
horizontal position to align them all on; in the example above, this becomes 5:

Move from 16 to 5: 66 fuel
Move from 1 to 5: 10 fuel
Move from 2 to 5: 6 fuel
Move from 0 to 5: 15 fuel
Move from 4 to 5: 1 fuel
Move from 2 to 5: 6 fuel
Move from 7 to 5: 3 fuel
Move from 1 to 5: 10 fuel
Move from 2 to 5: 6 fuel
Move from 14 to 5: 45 fuel

This costs a total of 168 fuel. This is the new cheapest possible outcome; the
old alignment position (2) now costs 206 fuel instead.

Determine the horizontal position that the crabs can align to using the least
fuel possible so they can make you an escape route! How much fuel must they
spend to align to that position?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt" -Raw

$crabPositions = $rawInput -split ',' | ForEach-Object { [int]$_ }

$crabStats = $crabPositions | Measure-Object -Maximum -Minimum

$results = @()
foreach ($position in ($crabStats.Minimum)..($crabStats.Maximum)) {
    $totalFuel = 0

    foreach ($crab in $crabPositions) {
        $distance = [math]::Abs($crab - $position)
        $stepCost = $distance * ($distance + 1) / 2
        $totalFuel += [int]$stepCost
    }
    # Note: We do a lot of extra work, purely to generate a chart for this part.
    # You can skip all the work once you come to a minimum. Track the smallest
    # value seen so far (initial value int32::MaxValue) and break once the
    # next value is larger than the smallest seen so far.
    $results += [PSCustomObject]@{
        Position  = $position
        TotalFuel = $totalFuel
    }
}

$results |
    Measure-Object -Property TotalFuel -Minimum |
    Select-Object -ExpandProperty Minimum

Import-Module "$PSScriptRoot\..\..\_modules\Chart.psm1"

$points = $results | ForEach-Object {
    [PSCustomObject]@{
        X = $_.Position
        Y = $_.TotalFuel
    }
}

$chartParams = @{
    Points      = $points
    Path        = "$PSScriptRoot\part2.png"
    Title       = "Fuel Consumption by Position - Part 2"
    XAxisTitle  = "Position"
    YAxisTitle  = "Total Fuel"
    Width       = 1920
    Height      = 1080
}
Save-LineChart @chartParams