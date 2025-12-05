<#
Now, the Elves just need help accessing as much of the paper as they can.

Once a roll of paper can be accessed by a forklift, it can be removed. Once a
roll of paper is removed, the forklifts might be able to access more rolls of
paper, which they might also be able to remove. How many total rolls of paper
could the Elves remove if they keep repeating this process?

Starting with the same example as above, here is one way you could remove as
many rolls of paper as possible, using highlighted @ to indicate that a roll of
paper is about to be removed, and using x to indicate that a roll of paper was
just removed:

Initial state:
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

Remove 13 rolls of paper:
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

Remove 12 rolls of paper:
.......x..
.@@.x.x.@x
x@@@@...@@
x.@@@@..x.
.@.@@@@.x.
.x@@@@@@.x
.x.@.@.@@@
..@@@.@@@@
.x@@@@@@@.
....@@@...

Remove 7 rolls of paper:
..........
.x@.....x.
.@@@@...xx
..@@@@....
.x.@@@@...
..@@@@@@..
...@.@.@@x
..@@@.@@@@
..x@@@@@@.
....@@@...

Remove 5 rolls of paper:
..........
..x.......
.x@@@.....
..@@@@....
...@@@@...
..x@@@@@..
...@.@.@@.
..x@@.@@@x
...@@@@@@.
....@@@...

Remove 2 rolls of paper:
..........
..........
..x@@.....
..@@@@....
...@@@@...
...@@@@@..
...@.@.@@.
...@@.@@@.
...@@@@@x.
....@@@...

Remove 1 roll of paper:
..........
..........
...@@.....
..x@@@....
...@@@@...
...@@@@@..
...@.@.@@.
...@@.@@@.
...@@@@@..
....@@@...

Remove 1 roll of paper:
..........
..........
...x@.....
...@@@....
...@@@@...
...@@@@@..
...@.@.@@.
...@@.@@@.
...@@@@@..
....@@@...

Remove 1 roll of paper:
..........
..........
....x.....
...@@@....
...@@@@...
...@@@@@..
...@.@.@@.
...@@.@@@.
...@@@@@..
....@@@...

Remove 1 roll of paper:
..........
..........
..........
...x@@....
...@@@@...
...@@@@@..
...@.@.@@.
...@@.@@@.
...@@@@@..
....@@@...

Stop once no more rolls of paper are accessible by a forklift. In this example,
a total of 43 rolls of paper can be removed.

Start with your original diagram. How many rolls of paper in total can be
removed by the Elves and their forklifts?
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

# Import Images module for saving png and gif
Import-Module "$PSScriptRoot\..\..\_modules\Images" -Force

# Make a temp folder for image files to live in
New-Item "$PSScriptRoot\Temp" -Type Directory -Force -ErrorAction Stop | Out-Null

$saveImageParams = @{
    Grid        = $grid
    FileName    = "$PSScriptRoot\Temp\000.png"
    TrueColour  = [System.Drawing.ColorTranslator]::FromHtml('#DEAA79')
    FalseColour = [System.Drawing.ColorTranslator]::FromHtml('#659287')
}
SaveBitGridToBitmap @saveImageParams

$removedTotal = 0
$iteration = 1
do {
    $changedCount = 0
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
                # Remove from the grid
                $grid[$x, $y] = $false
                $changedCount++
            }
        }
    }
    $removedTotal += $changedCount

    $saveImageParams = @{
        Grid        = $grid
        FileName    = "$PSScriptRoot\Temp\$('{0:D3}' -f $iteration).png"
        TrueColour  = [System.Drawing.ColorTranslator]::FromHtml('#DEAA79')
        FalseColour = [System.Drawing.ColorTranslator]::FromHtml('#659287')
    }
    SaveBitGridToBitmap @saveImageParams
    $iteration++
} while ($changedCount -gt 0)

# Emit the answer
$removedTotal

# Convert the folder of PNGs to a GIF for visualization
$gifParams = @{
    InputFolder = "$PSScriptRoot\Temp\"
    OutputGif   = "$PSScriptRoot\part2_visual.gif"
    Framerate   = 5
    Scale       = 20
}
Convert-PngFolderToBWGif @gifParams

# Clean up temp folder
Remove-Item "$PSScriptRoot\Temp" -Recurse -Force -Confirm:$false