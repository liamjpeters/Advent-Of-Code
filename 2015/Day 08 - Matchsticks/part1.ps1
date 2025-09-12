<#
Space on the sleigh is limited this year, and so Santa will be bringing his list
as a digital copy. He needs to know how much space it will take up when stored.

It is common in many programming languages to provide a way to escape special
characters in strings. For example, C, JavaScript, Perl, Python, and even PHP
handle special characters in very similar ways.

However, it is important to realize the difference between the number of
characters in the code representation of the string literal and the number of
characters in the in-memory string itself.

For example:

- "" is 2 characters of code (the two double quotes), but the string contains
  zero characters.
- "abc" is 5 characters of code, but 3 characters in the string data.
- "aaa\"aaa" is 10 characters of code, but the string itself contains six "a"
  characters and a single, escaped quote character, for a total of 7 characters
  in the string data.
- "\x27" is 6 characters of code, but the string itself contains just one - an
  apostrophe ('), escaped using hexadecimal notation.

Santa's list is a file that contains many double-quoted string literals, one on
each line. The only escape sequences used are \\ (which represents a single
backslash), \" (which represents a lone double-quote character), and \x plus
two hexadecimal characters (which represents a single character with that ASCII
code).

Disregarding the whitespace in the file, what is the number of characters of
code for string literals minus the number of characters in memory for the values
of the strings in total for the entire file?

For example, given the four strings above, the total number of characters of
string code (2 + 5 + 10 + 6 = 23) minus the total number of characters in memory
for string values (0 + 3 + 7 + 1 = 11) is 23 - 11 = 12.
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

class StringParser {
    [char[]] $String
    [int] $Index = 0

    StringParser([string]$inputString) {
        $this.String = $inputString.ToCharArray()
    }

    [bool] IsEndOfString() {
        return $this.Index -ge $this.String.Length
    }

    [char] Peek() {
        if ($this.IsEndOfString()) {
            return [char]0
        }
        return $this.String[$this.Index]
    }

    [char] Pop() {
        if ($this.IsEndOfString()) {
            return [char]0
        }
        $char = $this.String[$this.Index]
        $this.Index++
        return $char
    }
}

$parsedStrings = @()

foreach ($line in $rawInput) {
    $parsedString = [PSCustomObject]@{
        codeString = $line
        memoryString = ''
    }

    # Parsing notes:
    # - First and last character are to be ignored
    # - \\ (represents a single backslash)
    # - \" (represents a long double-quote character)
    # - \x followed by 2 characters

    # A simple peek/pop parser
    # Give it the string minus the opening and closing quotes
    $parser = [StringParser]::new($line.Substring(1,$line.Length - 2))

    # A string builder to build the new string
    $builder = [System.Text.StringBuilder]::new()

    while (-not $parser.IsEndOfString()) {
        $currentChar = $parser.Peek()

        # Is it the start of an escape sequence?
        if ($currentChar -eq '\') {

            # Consume the escape sequence
            $parser.Pop() | Out-Null

            # Look at the next character
            $escapeChar = $parser.Peek()

            switch ($escapeChar) {
                '\' { 
                    $builder.Append($parser.Pop()) | Out-Null
                }
                '"' {
                    $builder.Append($parser.Pop()) | Out-Null
                }
                'x' {
                    # Consume the x
                    $parser.Pop() | Out-Null
                    $hexDigits = [int]"0x$($parser.Pop())$($parser.Pop())"
                    $builder.Append([char]$hexDigits) | Out-Null
                }
                default {
                    Write-Warning "Found an unknown escape sequence, \'$escapeChar', in '$line'"
                    exit
                }
            }

        } else {
            # Add the character to the string
            $builder.Append($parser.Pop()) | Out-Null
        }
    }
    $parsedString.memoryString = $builder.ToString()

    $parsedStrings += $parsedString
}

$TotalCodeStringLength = $parsedStrings.codeString | ForEach-Object {
    $_.Length
} | Measure-Object -Sum | Select-Object -Expand Sum

$TotalMemoryStringLength = $parsedStrings.memoryString | ForEach-Object {
    $_.Length
} | Measure-Object -Sum | Select-Object -Expand Sum

$TotalCodeStringLength - $TotalMemoryStringLength