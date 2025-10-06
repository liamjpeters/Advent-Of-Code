<#
The Elves decide they don't want to visit an infinite number of houses. Instead,
each Elf will stop after delivering presents to 50 houses. To make up for it,
they decide to deliver presents equal to eleven times their number at each
house.

With these changes, what is the new lowest house number of the house to get at
least as many presents as the number in your puzzle input?
#>

$puzzleInput = 36000000
$tenthOfPuzzleInput = $puzzleInput / 10

# Preallocate integer array (index = house number)
$presents = [int[]]::new($tenthOfPuzzleInput + 1)

$answer = 0

for ($elf = 1; $elf -le $tenthOfPuzzleInput; $elf++) {
    # Eleves now deliver 11 times their number
    $gift = 11 * $elf
    # Keep track of number of deliveries
    $deliveries = 0
    for ($house = $elf; $house -le $tenthOfPuzzleInput; $house += $elf) {
        $presents[$house] += $gift
        $deliveries++
        # If the elf has delivered to 50 houses, stop
        if ($deliveries -ge 50) { break }
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