<#
In all the commotion, you realize that you forgot to seat yourself. At this
point, you're pretty apathetic toward the whole thing, and your happiness
wouldn't really go up or down regardless of who you sit next to. You assume
everyone else would be just as ambivalent about sitting next to you, too.

So, add yourself to the list, and give all happiness relationships that involve
you a score of 0.

What is the total change in happiness for the optimal seating arrangement that
actually includes yourself?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

$rawInput = Get-Content "$PSScriptRoot\input.txt"

# Keep track of each happiness using personName-otherPersonName = happiness
$happinessLookup = @{}

# Keep track of all names so we can get a unique set
$people = @()

# Regex for parsing the line
$pattern = '^(?<firstName>[A-Za-z]+) would (?<polarity>gain|lose) (?<units>\d+) happiness units by sitting next to (?<secondName>[A-Za-z]+)\.$'

# Parse the happiness
foreach ($line in $rawInput) {
    if ($line -match $pattern) {
        $first  = $Matches['firstName']
        $units  = [int]$Matches['units']
        $second = $Matches['secondName']
        $units  = if ($Matches['polarity'] -eq 'lose') { 
            -$units
        } else {
            $units
        }
        if ($people -notcontains $first) {
            $people += $first
        }
        $key = "$first-$second"
        if ($happinessLookup.ContainsKey($key)) {
            Write-Error "Parsing failed - attempted to insert duplicate key '$($key)'"
            exit
        }
        $happinessLookup[$key] = $units
    } else {
        Write-Error "Parsing failed - line does not match pattern: '$($line)'"
        exit
    }
}

# Add me to the list
foreach ($person in $people) {
    $happinessLookup["me-$person"] = 0
    $happinessLookup["$person-me"] = 0
}
$people += 'me'

# Import combinatorics module for Get-Permutations
Import-Module "$PSScriptRoot\..\..\_modules\Combinatorics.psm1" -Force

# Get each combination of people and caluclate the overall happiness for it
Get-Permutations $people | ForEach-Object {
    $permutation = $_.Permutation
    $happiness = 0
    # Look over the total count of people. Get the person either side of them
    for ($i = 0; $i -lt $permutation.Count; $i++) {
        # I am the current person
        $me = $permutation[$i]

        # Get who is to my left and right, ensuring the wrap as the table is
        # round
        $toMyLeft = if ($i -eq 0) {
            $permutation[$permutation.Count - 1]
        } else {
            $permutation[$i - 1]
        }
        $toMyRight = if ($i -eq $permutation.Count - 1) {
            $permutation[0]
        } else {
            $permutation[$i + 1]
        }

        # Add the happiness
        $happiness += $happinessLookup["$me-$toMyLeft"]
        $happiness += $happinessLookup["$me-$toMyRight"]
    }
    $happiness
} | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum