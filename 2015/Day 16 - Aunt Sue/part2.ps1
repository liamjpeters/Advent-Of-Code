<#
As you're about to send the thank you note, something in the MFCSAM's
instructions catches your eye. Apparently, it has an outdated retroencabulator,
and so the output from the machine isn't exact values - some of them indicate
ranges.

In particular, the cats and trees readings indicates that there are greater than
that many (due to the unpredictable nuclear decay of cat dander and tree
pollen), while the pomeranians and goldfish readings indicate that there are
fewer than that many (due to the modial interaction of magnetoreluctance).

What is the number of the real Aunt Sue?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

# Parse the sues and their props
$propPattern = '(?<Prop>\w+): (?<Value>\d+)'
$suePattern = '^Sue (?<SueNumber>\d+): (?<Props>.+)$'

$allSues = @()
foreach ($line in $rawInput) {
    if ($line -match $suePattern) {
        $sueNum = $matches['SueNumber']
        $props = @{}
        foreach ($propMatch in [regex]::Matches($matches['Props'], $propPattern)) {
            $props[$propMatch.Groups['Prop'].Value] = [int]$propMatch.Groups['Value'].Value
        }
        $allSues += [PSCustomObject]@{
            Number = $sueNum
            Props = $props
        }
    }
}


# Search the sues
$foundSue = $allSues | Where-Object {
    ($_.Props['children'] -eq $null -or $_.Props['children'] -eq 3) -and
    ($_.Props['cats'] -eq $null -or $_.Props['cats'] -gt 7) -and
    ($_.Props['samoyeds'] -eq $null -or $_.Props['samoyeds'] -eq 2) -and
    ($_.Props['pomeranians'] -eq $null -or $_.Props['pomeranians'] -lt 3) -and
    ($_.Props['akitas'] -eq $null -or $_.Props['akitas'] -eq 0) -and
    ($_.Props['vizslas'] -eq $null -or $_.Props['vizslas'] -eq 0) -and
    ($_.Props['goldfish'] -eq $null -or $_.Props['goldfish'] -lt 5) -and
    ($_.Props['trees'] -eq $null -or $_.Props['trees'] -gt 3) -and
    ($_.Props['cars'] -eq $null -or $_.Props['cars'] -eq 2) -and
    ($_.Props['perfumes'] -eq $null -or $_.Props['perfumes'] -eq 1)
}

# If we got back more than 1 sue - something went wrong
if ($foundSue.Count -ne 1) {
    Write-Error "Found too many sues"
    exit
}

# Write our sue's number
$foundSue.Number