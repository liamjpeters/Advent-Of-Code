<#
Neat, right? You might also enjoy hearing John Conway talking about this
sequence (that's Conway of Conway's Game of Life fame).

Now, starting again with the digits in your puzzle input, apply this process
50 times. What is the length of the new result?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt" -Raw

# Import Sequences for the 'Get-LookAndSay' function
Import-Module "$PSScriptRoot\..\..\_modules\Sequences.psm1"

$current = $rawInput
1..50 | ForEach-Object {
    $current = Get-LookAndSay $current
}
$current.Length