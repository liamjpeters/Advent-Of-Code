<#
.SYNOPSIS
    Increments a string of characters as if they were numbers, similar to
    alphabetical counting.

.DESCRIPTION
    The Increment-String function takes an input string and returns the next
    string in sequence, incrementing the last character. For example, 'aa'
    becomes 'ab', 'az' becomes 'ba', etc.
    This is useful for generating sequential identifiers or codes.

.PARAMETER InputString
    The string to be incremented.

.EXAMPLE
    Increment-String -InputString 'aa'
    Returns 'ab'

.EXAMPLE
    Increment-String -InputString 'az'
    Returns 'ba'

.NOTES
    Handles lowercase alphabetical characters. Behavior for other characters may
    vary.
#>
function Increment-String {
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]
        $InputString
    )

    $length = $InputString.Length
    $chars = $InputString.ToCharArray()
    $needsPrepend = $false

    # Iterate from right to left, using the index
    for ($i = $length - 1; $i -ge 0; $i--) {
        $char = $chars[$i]

        # If the character is 'z', it rolls over to 'a'
        if ($char -eq 'z') {
            $chars[$i] = 'a'
            # Loop continues to handle the next character to the left
        }
        # If it's any other letter, increment it and we're done
        else {
            $chars[$i] = [char]([int]$char + 1)
            $needsPrepend = $false
            break
        }

        # If we are at the beginning of the string and it rolled over,
        # we'll need to prepend a new character
        if ($i -eq 0) {
            $needsPrepend = $true
        }
    }

    # If all characters rolled over, prepend a new 'a'
    if ($needsPrepend) {
        return "a" + (-join $chars)
    }
    else {
        return -join $chars
    }
}