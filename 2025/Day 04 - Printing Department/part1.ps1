<#
You ride the escalator down to the printing department. They're clearly getting
ready for Christmas; they have lots of large rolls of paper everywhere, and
there's even a massive printer in the corner (to handle the really big print
jobs).

Decorating here will be easy: they can make their own decorations. What you
really need is a way to get further into the North Pole base while the elevators
are offline.

"Actually, maybe we can help with that," one of the Elves replies when you ask
for help. "We're pretty sure there's a cafeteria on the other side of the back
wall. If we could break through the wall, you'd be able to keep moving. It's too
bad all of our forklifts are so busy moving those big rolls of paper around."

If you can optimize the work the forklifts are doing, maybe they would have time
to spare to break through the wall.

The rolls of paper (@) are arranged on a large grid; the Elves even have a
helpful diagram (your puzzle input) indicating where everything is located.

For example:

..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
The forklifts can only access a roll of paper if there are fewer than four rolls
of paper in the eight adjacent positions. If you can figure out which rolls of
paper the forklifts can access, they'll spend less time looking and more time
breaking down the wall to the cafeteria.

In this example, there are 13 rolls of paper that can be accessed by a forklift
(marked with x):

..xx.xx@x.
x@@.@.@.@@
@@@@@.x.@@
@.@@@@..@.
x@.@@@@.@x
.@@@@@@@.@
.@.@.@.@@@
x.@@@.@@@@
.@@@@@@@@.
x.x.@@@.x.

Consider your complete diagram of the paper roll locations. How many rolls of
paper can be accessed by a forklift?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

# Store the grid as a 2D array of bools (paper roll present = $true)
$grid = [bool[,]]::new($rawInput[0].Length, $rawInput.Length)

# read the input into the grid
for ($y = 0; $y -lt $rawInput.Length; $y++) {
    for ($x = 0; $x -lt $rawInput[$y].Length; $x++) {
        if ($rawInput[$y][$x] -eq '@') {
            $grid[$x, $y] = $true
        }
    }
}

$accessibleCount = 0
for ($y = 0; $y -lt $rawInput.Length; $y++) {
    for ($x = 0; $x -lt $rawInput[$y].Length; $x++) {
        if (-not $grid[$x, $y]) {
            continue
        }
        # For each square, count adjacent paper rolls
        $adjacentCount = 0
        for ($dy = -1; $dy -le 1; $dy++) {
            for ($dx = -1; $dx -le 1; $dx++) {
                if ($dx -eq 0 -and $dy -eq 0) {
                    continue
                }
                $nx = $x + $dx
                $ny = $y + $dy
                if ($nx -ge 0 -and $nx -lt $rawInput[$y].Length -and
                    $ny -ge 0 -and $ny -lt $rawInput.Length) {
                    if ($grid[$nx, $ny]) {
                        $adjacentCount++
                    }
                }
            }
        }
        if ($adjacentCount -lt 4) {
            $accessibleCount++
        }
    }
}
$accessibleCount