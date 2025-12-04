<#
The escalator doesn't move. The Elf explains that it probably needs more joltage
to overcome the static friction of the system and hits the big red "joltage
limit safety override" button. You lose count of the number of times she needs
to confirm "yes, I'm sure" and decorate the lobby a bit while you wait.

Now, you need to make the largest joltage by turning on exactly twelve batteries
within each bank.

The joltage output for the bank is still the number formed by the digits of the
batteries you've turned on; the only difference is that now there will be 12
digits in each bank's joltage output instead of two.

Consider again the example from before:

987654321111111
811111111111119
234234234234278
818181911112111

Now, the joltages are much larger:

- In 987654321111111, the largest joltage can be found by turning on everything
  except some 1s at the end to produce 987654321111.
- In the digit sequence 811111111111119, the largest joltage can be found by
  turning on everything except some 1s, producing 811111111119.
- In 234234234234278, the largest joltage can be found by turning on everything
  except a 2 battery, a 3 battery, and another 2 battery near the start to
  produce 434234234278.
- In 818181911112111, the joltage 888911112111 is produced by turning on
  everything except some 1s near the front.

The total output joltage is now much larger: 987654321111 + 811111111119 +
434234234278 + 888911112111 = 3121910778619.
#>

function Get-MaxNumberOfLengthWindow {
    # We build the result one digit at a time. For each position, we look at a
    # "window" of allowed digits in the original string: from the current start
    # index up to the last index we can choose from while still leaving enough
    # digits to reach total length K. Within that window we pick the largest
    # (left-most) digit, append it to the result, and then move the window start
    # to just after that digit. Repeating this K times yields the
    # lexicographically largest K-digit subsequence that preserves the original
    # order.
    param(
        [Parameter(Mandatory)]
        [string] $Digits,

        # The number of digits we want to pick
        [Parameter(Mandatory)]
        [int] $K
    )

    # We have a string of length N
    $n = $Digits.Length

    # Build result as we go
    $resultChars = [System.Text.StringBuilder]::new()

    $startIdx = 0
    for ($picked = 0; $picked -lt $K; $picked++) {
        $remainingToPick = $K - $picked

        # last index we are allowed to pick from
        $maxIdx = $n - $remainingToPick

        # Find max digit in [startIdx .. maxIdx]
        # char comparisons are fine here
        $bestDigit = '0'
        $bestIndex = $startIdx

        for ($i = $startIdx; $i -le $maxIdx; $i++) {
            $d = $Digits[$i]

            if ($d -gt $bestDigit) {
                $bestDigit = $d
                $bestIndex = $i

                # Early-out: can't beat '9'
                if ($bestDigit -eq '9') { break }
            }
        }

        $resultChars.Append($bestDigit.ToString()) | Out-Null
        $startIdx = $bestIndex + 1
    }

    $resultChars.ToString()
}

$rawInput = Get-Content "$PSScriptRoot\input.txt"

$totalJoltage = 0

foreach ($bank in $rawInput) {
    $maxJoltage = Get-MaxNumberOfLengthWindow -Digits $bank -K 12

    $totalJoltage += $maxJoltage -as [int64]
}
$totalJoltage