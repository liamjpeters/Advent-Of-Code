<#
Santa is delivering presents to an infinite two-dimensional grid of houses.

He begins by delivering a present to the house at his starting location, and
then an elf at the North Pole calls him via radio and tells him where to move
next. Moves are always exactly one house to the north (^), south (v), east (>),
or west (<). After each move, he delivers another present to the house at his
new location.

However, the elf back at the north pole has had a little too much eggnog, and so
his directions are a little off, and Santa ends up visiting some houses more
than once.

For example:

- > delivers presents to 2 houses: one at the starting location, and one to the
  east.
- ^>v< delivers presents to 4 houses in a square, including twice to the house
  at his starting/ending location.
- ^v^v^v^v^v delivers a bunch of presents to some very lucky children at only 2
  houses.

How many houses receive at least one present?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt" -Raw

# Santa starts at 0,0
$x = 0
$y = 0

# Keep a track of all the locations Santa has visited and how many times
$visitedLocs = @{
    "$x,$y" = 1
}

foreach ($index in 0..$($rawInput.Length - 1)) {
    $instruction = $rawInput[$index]
    switch ($instruction) {
        '^' { $y++; break }
        'v' { $y--; break }
        '>' { $x++; break }
        '<' { $x--; break }
        default {
            throw "unknown instruction '$instruction'"
        }
    }
    $key = "$x,$y"

    # Check if we've been here before and increment the visit count if so
    if ($visitedLocs.ContainsKey($key)) {
        $visitedLocs[$key]++
        continue
    }
    # If not, insert a 1
    $visitedLocs[$key] = 1
}

$visitedLocs.Count