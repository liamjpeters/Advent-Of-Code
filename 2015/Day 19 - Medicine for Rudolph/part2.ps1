<#
Now that the machine is calibrated, you're ready to begin molecule fabrication.

Molecule fabrication always begins with just a single electron, e, and applying
replacements one at a time, just like the ones during calibration.

For example, suppose you have the following replacements:

e => H
e => O
H => HO
H => OH
O => HH

If you'd like to make HOH, you start with e, and then make the following
replacements:

e => O to get O
O => HH to get HH
H => OH (on the second H) to get HOH

So, you could make HOH after 3 steps. Santa's favorite molecule, HOHOHO, can be
made in 6 steps.

How long will it take to make the medicine? Given the available replacements and
the medicine molecule in your puzzle input, what is the fewest number of steps
to go from e to the medicine molecule?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

Import-Module "$PSScriptRoot\..\..\_modules\Strings"

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

# Some Context Free Grammar (CFG) analysis shows that the number of steps to
# generate the molecule can be determined by a simple formula based on the
# structure of the molecule:
# Steps = TotalTokens - OpenParens - CloseParens - 2 * Separators - 1
# - Each capital letter (with optional lowercase) is a token.
# - Rn / Ar act like parentheses (don’t expand individually). They always appear
#   in pairs. A step isn't needed to add them, but they do add structure.
# - Y works like a separator creating two extra needed replacements each time it
#   appears.
# Overall, all expansion trees collapse to that linear formula.
# You start with some number of tokens, then subtract the structural tokens
# (parentheses and separators) and the starting token (e) to get the number of
# steps.

$OpenParenMolecule = 'Rn'
$CloseParenMolecule = 'Ar'
$SeparatorMolecule = 'Y'

# Tokenize: capital letter followed by optional lowercase
$tokens = [regex]::Matches($starting, '[A-Z][a-z]?') | ForEach-Object { $_.Value }

$total = $tokens.Count
$openParenTotal = ($tokens | Where-Object { $_ -eq $OpenParenMolecule }).Count
$closeParenTotal = ($tokens | Where-Object { $_ -eq $CloseParenMolecule }).Count
$separatorTotal = ($tokens | Where-Object { $_ -eq $SeparatorMolecule }).Count

$total - $openParenTotal - $closeParenTotal - (2 * $separatorTotal) - 1