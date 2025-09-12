<#
Every year, Santa manages to deliver all of his presents in a single night.

This year, however, he has some new locations to visit; his elves have provided
him the distances between every pair of locations. He can start and end at any
two (different) locations he wants, but he must visit each location exactly
once. What is the shortest distance he can travel to achieve this?

For example, given the following distances:

London to Dublin = 464
London to Belfast = 518
Dublin to Belfast = 141
The possible routes are therefore:

Dublin -> London -> Belfast = 982
London -> Dublin -> Belfast = 605
London -> Belfast -> Dublin = 659
Dublin -> Belfast -> London = 659
Belfast -> Dublin -> London = 605
Belfast -> London -> Dublin = 982
The shortest of these is London -> Dublin -> Belfast = 605, and so the answer is
605 in this example.

What is the distance of the shortest route?
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
} | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum