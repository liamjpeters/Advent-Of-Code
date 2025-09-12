<#
Now, given the same instructions, find the position of the first character that
causes him to enter the basement (floor -1). The first character in the
instructions has position 1, the second character has position 2, and so on.

For example:

) causes him to enter the basement at character position 1.
()()) causes him to enter the basement at character position 5.
What is the position of the character that causes Santa to first enter the
basement?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt" -Raw

# Start on floor 0
$floor = 0

# Go through each character, increment for `(`, decrement for `)`
foreach ($index in 0..$($rawInput.Length - 1)) {
    switch ($rawInput[$index]) {
        '(' { $floor++ }
        ')' { $floor-- }
        Default {
            throw "Unhandled character $($rawInput[$index])"
        }
    }
    if ($floor -lt 0) {
        Write-Host "$($index+1)"
        return
    }
}
Write-Host "Never entered basement"