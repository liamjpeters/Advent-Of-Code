<#
Suppose the lanternfish live forever and have unlimited food and space. Would
they take over the entire ocean?

After 256 days in the example above, there would be a total of 26984457539
lanternfish!

How many lanternfish would there be after 256 days?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt" -Raw

# Keep track of how many fish there are with each timer value
# We meed tp ise Int64 to avoid int32 overflowing
[int64[]]$fishTimers = @(0,0,0,0,0,0,0,0,0)

$rawInput -split ',' | ForEach-Object {
    $fishTimers[([int64]$_)]++
}

foreach ($day in 1..256) {
    # Number at 0
    $numAtZero = $fishTimers[0]
    # Shift all timers down by 1
    for ($i = 0; $i -lt 8; $i++) {
        $fishTimers[$i] = $fishTimers[$i + 1]
    }
    # Reset fish that were at 0 to 6
    $fishTimers[6] += $numAtZero
    # Add new fish with timer 8
    $fishTimers[8] = $numAtZero
}

$fishTimers | Measure-Object -Sum | Select-Object -ExpandProperty Sum