<#
Rudolph the Red-Nosed Reindeer is sick! His nose isn't shining very brightly,
and he needs medicine.

Red-Nosed Reindeer biology isn't similar to regular reindeer biology; Rudolph is
going to need custom-made medicine. Unfortunately, Red-Nosed Reindeer chemistry
isn't similar to regular reindeer chemistry, either.

The North Pole is equipped with a Red-Nosed Reindeer nuclear fusion/fission
plant, capable of constructing any Red-Nosed Reindeer molecule you need. It
works by starting with some input molecule and then doing a series of
replacements, one per step, until it has the right molecule.

However, the machine has to be calibrated before it can be used. Calibration
involves determining the number of molecules that can be generated in one step
from a given starting point.

For example, imagine a simpler machine that supports only the following
replacements:

H => HO
H => OH
O => HH

Given the replacements above and starting with HOH, the following molecules
could be generated:

HOOH (via H => HO on the first H).
HOHO (via H => HO on the second H).
OHOH (via H => OH on the first H).
HOOH (via H => OH on the second H).
HHHH (via O => HH).

So, in the example above, there are 4 distinct molecules (not five, because HOOH
appears twice) after one replacement from HOH. Santa's favorite molecule,
HOHOHO, can become 7 distinct molecules (over nine replacements: six from H,
and three from O).

The machine replaces without regard for the surrounding characters. For example,
given the string H2O, the transition H => OO would result in OO2O.

Your puzzle input describes all of the possible replacements and, at the bottom,
the medicine molecule for which you need to calibrate the machine. How many
distinct molecules can be created after all the different ways you can do one
replacement on the medicine molecule?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

function ReplaceFirstAtOffset {
    param(
        # The haystack to search
        [Parameter(Mandatory)]
        [string]
        $InputString,
        # The needle to use
        [Parameter(Mandatory)]
        [string]
        $Pattern,
        # What to replace the needle with
        [Parameter(Mandatory)]
        [string]
        $Replacement,
        # How far into the string to start the search
        [Parameter(Mandatory)]
        [int]
        $Offset
    )
    $before = $InputString.Substring(0, $Offset)
    $after = $InputString.Substring($Offset+$Pattern.Length)
    return "$before$Replacement$after"
}

# Parse input
$replacements = @()
$starting = ''

foreach ($line in $rawInput) {
    if ([string]::IsNullOrEmpty($line)) { continue }

    if ($line -match '^(?<Needle>.*?) => (?<Replacement>.*?)$') {
        $replacements += [PSCustomObject]@{
            Needle      = $Matches['Needle']
            Replacement = $Matches['Replacement']
        }
        continue
    }

    $starting = $line
}

# For each replacement, find each instance of the string to replace. Add a copy
# of the string with the replacement to a list.
$listOfStrings = @()

foreach ($replacement in $replacements) {
    $startIndex = 0
    while ($startIndex -le ($starting.Length - $replacement.Needle.Length)) {
        $foundAt = $starting.IndexOf($replacement.Needle, $startIndex)
        if ($foundAt -eq -1) { break }
        $listOfStrings += ReplaceFirstAtOffset -InputString $starting -Pattern $replacement.Needle -Replacement $replacement.Replacement -Offset $foundAt
        $startIndex = $foundAt + 1  # Move forward by 1 to allow overlaps
    }
}

$listOfStrings |
    Select-Object -Unique |
    Measure-Object |
    Select-Object -Expand Count
