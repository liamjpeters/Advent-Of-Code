<#
To keep the Elves busy, Santa has them deliver some presents by hand,
door-to-door. He sends them down a street with infinite houses numbered
sequentially: 1, 2, 3, 4, 5, and so on.

Each Elf is assigned a number, too, and delivers presents to houses based on
that number:

- The first Elf (number 1) delivers presents to every house: 1, 2, 3, 4, 5, ....
- The second Elf (number 2) delivers presents to every second house: 2, 4, 6, 8,
  10, ....
- Elf number 3 delivers presents to every third house: 3, 6, 9, 12, 15, ....

There are infinitely many Elves, numbered starting with 1. Each Elf delivers
presents equal to ten times his or her number at each house.

So, the first nine houses on the street end up like this:

House 1 got 10 presents.
House 2 got 30 presents.
House 3 got 40 presents.
House 4 got 70 presents.
House 5 got 60 presents.
House 6 got 120 presents.
House 7 got 80 presents.
House 8 got 150 presents.
House 9 got 130 presents.

The first house gets 10 presents: it is visited only by Elf 1, which delivers
1 * 10 = 10 presents. The fourth house gets 70 presents, because it is visited
by Elves 1, 2, and 4, for a total of 10 + 20 + 40 = 70 presents.

What is the lowest house number of the house to get at least as many presents as
the number in your puzzle input?
#>

$puzzleInput = 36000000

# Each house gets 10 times the sum of its divisors
$tenthOfPuzzleInput = $puzzleInput / 10

# Import for the Get-Divisors function
Import-Module "$PSScriptRoot\..\..\_modules\Maths.psm1" -Force

# Preallocate integer array (index = house number)
$presents = [int[]]::new($tenthOfPuzzleInput + 1)

$answer = 0

for ($elf = 1; $elf -le $tenthOfPuzzleInput; $elf++) {
    $gift = 10 * $elf
    for ($house = $elf; $house -le $tenthOfPuzzleInput; $house += $elf) {
        $presents[$house] += $gift
    }
    if ($answer -eq 0 -and $presents[$elf] -ge $puzzleInput) {
        $answer = $elf
        break
    }
}

if ($answer -eq 0) {
    for ($h = 1; $h -le $tenthOfPuzzleInput; $h++) {
        if ($presents[$h] -ge $puzzleInput) { $answer = $h; break }
    }
}

$answer