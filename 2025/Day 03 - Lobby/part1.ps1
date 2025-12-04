<#
You descend a short staircase, enter the surprisingly vast lobby, and are
quickly cleared by the security checkpoint. When you get to the main elevators,
however, you discover that each one has a red light above it: they're all
offline.

"Sorry about that," an Elf apologizes as she tinkers with a nearby control
panel. "Some kind of electrical surge seems to have fried them. I'll try to get
them online soon."

You explain your need to get further underground. "Well, you could at least take
the escalator down to the printing department, not that you'd get much further
than that without the elevators working. That is, you could if the escalator
weren't also offline."

"But, don't worry! It's not fried; it just needs power. Maybe you can get it
running while I keep working on the elevators."

There are batteries nearby that can supply emergency power to the escalator for
just such an occasion. The batteries are each labeled with their joltage rating,
a value from 1 to 9. You make a note of their joltage ratings (your puzzle
input). For example:

987654321111111
811111111111119
234234234234278
818181911112111

The batteries are arranged into banks; each line of digits in your input
corresponds to a single bank of batteries. Within each bank, you need to turn on
exactly two batteries; the joltage that the bank produces is equal to the number
formed by the digits on the batteries you've turned on. For example, if you have
a bank like 12345 and you turn on batteries 2 and 4, the bank would produce 24
jolts. (You cannot rearrange batteries.)

You'll need to find the largest possible joltage each bank can produce. In the
above example:

- In 987654321111111, you can make the largest joltage possible, 98, by turning
  on the first two batteries.
- In 811111111111119, you can make the largest joltage possible by turning on
  the batteries labeled 8 and 9, producing 89 jolts.
- In 234234234234278, you can make 78 by turning on the last two batteries
  (marked 7 and 8).
- In 818181911112111, the largest joltage you can produce is 92.

The total output joltage is the sum of the maximum joltage from each bank, so in
this example, the total output joltage is 98 + 89 + 78 + 92 = 357.

There are many batteries in front of you. Find the maximum joltage possible from
each bank; what is the total output joltage?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

$totalJoltage = 0

foreach ($bank in $rawInput) {
    $maxJoltage = 0
    $length = $bank.Length

    # Loop through each pair of digits in the bank
    # Keep track of the largest joltage found
    for ($i = 0; $i -lt $length - 1; $i++) {
        # Indexing into the string gives us a char, convert to int
        # Note: We can't just cast it as that would take the ASCII value
        #       e.g. '9' would become 57 instead of 9
        $firstDigit = [Convert]::ToInt32($bank[$i].ToString())

        for ($j = $i + 1; $j -lt $length; $j++) {
            $secondDigit = [Convert]::ToInt32($bank[$j].ToString())
            $joltage = $firstDigit * 10 + $secondDigit

            if ($joltage -gt $maxJoltage) {
                $maxJoltage = $joltage
            }
        }
    }

    $totalJoltage += $maxJoltage
}
$totalJoltage