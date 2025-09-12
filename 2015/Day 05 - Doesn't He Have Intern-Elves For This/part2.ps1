<#
Realizing the error of his ways, Santa has switched to a better model of
determining whether a string is naughty or nice. None of the old rules apply, as
they are all clearly ridiculous.

Now, a nice string is one with all of the following properties:

- It contains a pair of any two letters that appears at least twice in the
  string without overlapping, like xyxy (xy) or aabcdefgaa (aa), but not like
  aaa (aa, but it overlaps).
- It contains at least one letter which repeats with exactly one letter between
  them, like xyx, abcdefeghi (efe), or even aaa.

For example:

- qjhvhtzxzqqjkmpb is nice because is has a pair that appears twice (qj) and a
  letter that repeats with exactly one letter between them (zxz).
- xxyxx is nice because it has a pair that appears twice and a letter that
  repeats with one between, even though the letters used by each rule overlap.
- uurcxstgmygtbstg is naughty because it has a pair (tg) but no repeat with a
  single letter between them.
- ieodomkazucvgmuy is naughty because it has a repeating letter with one between
  (odo), but no pair that appears twice.

How many strings are nice under these new rules?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

$niceStringCount = 0

foreach ($string in $rawInput) {
    # 1. Repeated Pair
    # Regex works as follows:
    # (..) Creates a capturing group that matches any two characters and stores
    #      them.
    # .*   Matches any character zero or more times. Skips the characters
    #      between the first and second instance of the pair.
    # \1   This is a backreference to the first capture group. It asserts that
    #      the text matched by the first group MUST appear again.
    if ($string -notmatch '(..).*\1') {
        continue
    }

    # 2. SpacedRepeat
    # Regex works as follows:
    # (.)  Creates a capturing group that matches and stores any single
    #      character.
    # .    This matches any single character
    # \1   This is a backreference to the first capture group. It asserts that
    #      the text matched by the first group MUST appear again.
    if ($string -notmatch '(.).\1') {
        continue
    }
    $niceStringCount++
}
$niceStringCount