<#
.SYNOPSIS
    Generates the next number in the Look-and-Say sequence based on the provided
    input.

.DESCRIPTION
    The Get-LookAndSay function takes a numeric string as input and returns the
    next number in the Look-and-Say sequence.
    The Look-and-Say sequence is constructed by describing the count and value
    of consecutive digits in the input.

.PARAMETER Input
    The numeric string to process and generate the next Look-and-Say sequence
    value.

.EXAMPLE
    PS> Get-LookAndSay -Input "1"
    11

.EXAMPLE
    PS> Get-LookAndSay -Input "21"
    1211

.NOTES
    The function tests that the input is a valid numeric string. If it is not,
    an exception is thrown.
#>
function Get-LookAndSay {
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidatePattern('^\d+$')]
        [string]
        $For
    )
    $result = [System.Text.StringBuilder]::new()

    $currentChar = ''
    $currentCharCount = 0
    foreach ($digit in $For.ToCharArray()) {
        # If this is the first digit we're reading, set it as our current and
        # set the counter to 1
        if ($currentChar -eq '') {
            $currentChar = $digit
            $currentCharCount = 1
            continue
        }
        # If this digit is the same as our current, increment the counter
        if ($digit -eq $currentChar) {
            $currentCharCount++
            continue
        }

        # Emit the count and digit to the result
        $result.Append("$currentCharCount$currentChar") | Out-Null
        $currentChar = $digit
        $currentCharCount = 1
    }
    # When we fall out the end, flush the final count and digit
    $result.Append("$currentCharCount$currentChar") | Out-Null
    return $result.ToString()
}
