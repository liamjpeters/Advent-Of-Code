<#
Santa's password expired again. What's the next one?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt" -Raw

# We essentially treat our text as a base-26 number, where each "digit"
# corresponds to a letter of the alphabet.

# Import Text for the 'Increment-String' function
Import-Module "$PSScriptRoot\..\..\_modules\Text.psm1" -DisableNameChecking

$current = $rawInput

do {
    $passwordValid = $false
    $current = Increment-String $current

    # Check confusing letters
    if ($current -notmatch '^(?!.*[iol])') {
        continue
    }

    # Check for two different pairs of letters
    if ($current -notmatch '([a-z])\1.*(?!\1)([a-z])\2') {
        continue
    }

    # Note, I couldn't think of an even slightly better way to do this...
    if ($current -notmatch '(abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)') {
        continue
    }
    $passwordValid = $true
} while (-not $passwordValid)

# Copy-paste to the rescue...

do {
    $passwordValid = $false
    $current = Increment-String $current

    # Check confusing letters
    if ($current -notmatch '^(?!.*[iol])') {
        continue
    }

    # Check for two different pairs of letters
    if ($current -notmatch '([a-z])\1.*(?!\1)([a-z])\2') {
        continue
    }

    # Note, I couldn't think of an even slightly better way to do this...
    if ($current -notmatch '(abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)') {
        continue
    }
    $passwordValid = $true
} while (-not $passwordValid)

$current