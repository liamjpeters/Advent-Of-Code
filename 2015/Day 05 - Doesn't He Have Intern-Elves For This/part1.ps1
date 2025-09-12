<#
Santa needs help figuring out which strings in his text file are naughty or
nice.

A nice string is one with all of the following properties:

- It contains at least three vowels (aeiou only), like aei, xazegov, or
  aeiouaeiouaeiou.
- It contains at least one letter that appears twice in a row, like xx, abcdde
  (dd), or aabbccdd (aa, bb, cc, or dd).
- It does not contain the strings ab, cd, pq, or xy, even if they are part of
  one of the other requirements.

For example:

- ugknbfddgicrmopn is nice because it has at least three vowels (u...i...o...),
  a double letter (...dd...), and none of the disallowed substrings.
- aaa is nice because it has at least three vowels and a double letter, even
  though the letters used by different rules overlap.
- jchzalrnumimnmhp is naughty because it has no double letter.
- haegwjzuvuyypxyu is naughty because it contains the string xy.
- dvszwmarrgswjxmb is naughty because it contains only one vowel.

How many strings are nice?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

$niceStringCount = 0

foreach ($string in $rawInput) {
    # 1. Check for at least 3 vowels
    $vowelCount = $string |
        Select-String -Pattern '[aeiou]' -AllMatches |
        Select-Object -ExpandProperty Matches |
        Measure-Object |
        Select-Object -ExpandProperty Count

    if ($vowelCount -lt 3) {
        continue
    }

    # 2. Double Letter
    $noDoubleLetter = $string -notmatch '(.)\1'

    if ($noDoubleLetter) {
        continue
    }

    # 3. Check for forbidden strings
    $hasForbiddenStrings = $string -match 'ab|cd|pq|xy'
    if ($hasForbiddenStrings) {
        continue
    }
    $niceStringCount++
}
$niceStringCount