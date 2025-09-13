<#
Your cookie recipe becomes wildly popular! Someone asks if you can make another
recipe that has exactly 500 calories per cookie (so they can use it as a meal
replacement). Keep the rest of your award-winning process the same (100
teaspoons, same ingredients, same scoring system).

For example, given the ingredients above, if you had instead selected 40
teaspoons of butterscotch and 60 teaspoons of cinnamon (which still adds to
100), the total calorie count would be 40*8 + 60*3 = 500. The total score
would go down, though: only 57600000, the best you can do in such trying
circumstances.

Given the ingredients in your kitchen and their properties, what is the total
score of the highest-scoring cookie you can make with a calorie total of 500?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

$pattern = '^(?<Name>\w+): capacity (?<Capacity>-?\d+), durability (?<Durability>-?\d+), flavor (?<Flavor>-?\d+), texture (?<Texture>-?\d+), calories (?<Calories>-?\d+)$'

$incredients = @()

foreach ($line in $rawInput) {
    if ($line -match $pattern) {
        $incredients += [PSCustomObject]@{
            Name       = $Matches['Name']
            Capacity   = [int]$Matches['Capacity']
            Durability = [int]$Matches['Durability']
            Flavor     = [int]$Matches['Flavor']
            Texture    = [int]$Matches['Texture']
            Calories   = [int]$Matches['Calories']
        }
    } else {
        Write-Error "Parse Error - Line did not match pattern: '$($line)'"
        exit
    }
}

# Import Combinatorics module for `Get-CombinationsWithSum` function.
Import-Module "$PSScriptRoot\..\..\_modules\AOC" -Force

$comboParams = @{
    NumElements = $incredients.Count
    Sum         = 100
    Min         = 1
}

Get-CombinationsWithSum @comboParams | ForEach-Object {
    $combo = $_.Combination
    $cookieCombo = [PSCustomObject]@{
        Capacity = 0
        Durability = 0
        Flavor = 0
        Texture = 0
        Calories = 0
        Total = 0
    }
    for ($i = 0; $i -lt $incredients.Count; $i++) {
        $cookieCombo.Capacity += $combo[$i] * $incredients[$i].Capacity
        $cookieCombo.Durability += $combo[$i] * $incredients[$i].Durability
        $cookieCombo.Flavor += $combo[$i] * $incredients[$i].Flavor
        $cookieCombo.Texture += $combo[$i] * $incredients[$i].Texture
        $cookieCombo.Calories += $combo[$i] * $incredients[$i].Calories
    }
    $cookieCombo.Total = [Math]::Max(0,$cookieCombo.Capacity) *
        [Math]::Max(0,$cookieCombo.Durability) *
        [Math]::Max(0,$cookieCombo.Flavor) *
        [Math]::Max(0,$cookieCombo.Texture)
    $cookieCombo
} | Where-Object {
    $_.Calories -eq 500
} | Measure-Object -Maximum -Property Total | 
    Select-Object -ExpandProperty Maximum