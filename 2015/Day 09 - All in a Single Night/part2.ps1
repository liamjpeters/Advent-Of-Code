<#
The next year, just to show off, Santa decides to take the route with the
longest distance instead.

He can still start and end at any two (different) locations he wants, and he
still must visit each location exactly once.

For example, given the distances above, the longest route would be 982 via (for
example) Dublin -> London -> Belfast.

What is the distance of the longest route?
#>


$rawInput = Get-Content "$PSScriptRoot\input.txt"

# Start by parsing the input
$distanceMap = @{}
$locations = @()

$distancePattern = '^(.*?) to (.*?) = (\d+)$'

foreach ($line in $rawInput) {
    $match = [regex]::Match($line, $distancePattern)

    # We should always match, but if we don't - warn and exit.
    if (-not $match.Success) {
        Write-Warning "Line not in expected format: '$line'"
        exit
    }

    # Gather the required variables
    $location1 = $match.Groups[1].Value
    $location2 = $match.Groups[2].Value
    $distance = [int]$match.Groups[3].Value

    # Add the locations to the location list
    $locations += $location1
    $locations += $location2

    # Add the distance combo to the list of distances
    $distanceMap["$location1-$location2"] = $distance
}

# Get the unique list of locations
$locations = $locations | Select-Object -Unique | Sort-Object

# Import Combinatorics module for Permutations function
Import-Module "$PSScriptRoot\..\..\_modules\Combinatorics" -Force

# Get all of the possible combinations
$Permutations = Get-Permutations -Items $locations

$Permutations | ForEach-Object {
    $distanceTotal = 0
    $permutation = $_.Permutation
    for ($i = 0; $i -lt $permutation.Count - 1; $i++) {
        $loc1 = $permutation[$i]
        $loc2 = $permutation[$i+1]
        $distanceTotal += $distanceMap["$loc1-$loc2"] ?? $distanceMap["$loc2-$loc1"]
    }
    $distanceTotal
} | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum