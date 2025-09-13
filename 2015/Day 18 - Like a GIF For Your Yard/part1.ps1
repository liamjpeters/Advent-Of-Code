<#
After the million lights incident, the fire code has gotten stricter: now, at
most ten thousand lights are allowed. You arrange them in a 100x100 grid.

Never one to let you down, Santa again mails you instructions on the ideal
lighting configuration. With so few lights, he says, you'll have to resort to
animation.

Start by setting your lights to the included initial configuration (your puzzle
input). A # means "on", and a . means "off".

Then, animate your grid in steps, where each step decides the next configuration
based on the current one. Each light's next state (either on or off) depends on
its current state and the current states of the eight lights adjacent to it
(including diagonals). Lights on the edge of the grid might have fewer than
eight neighbors; the missing ones always count as "off".

For example, in a simplified 6x6 grid, the light marked A has the neighbors
numbered 1 through 8, and the light marked B, which is on an edge, only has the
neighbors marked 1 through 5:

1B5...
234...
......
..123.
..8A4.
..765.

The state a light should have next is based on its current state (on or off)
plus the number of neighbors that are on:

- A light which is on stays on when 2 or 3 neighbors are on, and turns off
  otherwise.
- A light which is off turns on if exactly 3 neighbors are on, and stays off
  otherwise.

All of the lights update simultaneously; they all consider the same current
state before moving to the next.

Here's a few steps from an example configuration of another 6x6 grid:

Initial state:
.#.#.#
...##.
#....#
..#...
#.#..#
####..

After 1 step:
..##..
..##.#
...##.
......
#.....
#.##..

After 2 steps:
..###.
......
..###.
......
.#....
.#....

After 3 steps:
...#..
......
...#..
..##..
......
......

After 4 steps:
......
......
..##..
..##..
......
......

After 4 steps, this example has four lights on.

In your grid of 100x100 lights, given your initial configuration, how many
lights are on after 100 steps?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"
$gridSize = $rawInput[0].Length
$Steps = 100

function Get-NumTrueNeighbours {
    [OutputType([Int32])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [bool[, ]]
        $Grid,
        [Int32]
        $X,
        [Int32]
        $Y
    )

    $height = $Grid.GetLength(0)
    $width = $Grid.GetLength(1)
    $count = 0

    foreach ($dy in -1..1) {
        foreach ($dx in -1..1) {
            if ($dx -eq 0 -and $dy -eq 0) { continue } # skip self
            $nx = $X + $dx
            $ny = $Y + $dy
            if ($nx -ge 0 -and $nx -lt $width -and
                $ny -ge 0 -and $ny -lt $height) {
                if ($Grid[$ny, $nx]) { $count++ }
            }
        }
    }
    return $count
}

# Create the array of bools. They're 0 ($false) initialised
$grid = [bool[, ]]::new($gridSize, $gridSize)

for ($y = 0; $y -lt $grid.GetLength(0); $y++) {
    for ($x = 0; $x -lt $grid.GetLength(1); $x++) {
        if ($rawInput[$y][$x] -eq '#') {
            $grid[$x, $y] = $true
        }
    }
}

# Make a temp folder for image files to live in
New-Item "$PSScriptRoot\Temp" -Type Directory -Force -ErrorAction Stop |
    Out-Null

# Import Images module for saving png and gif
Import-Module "$PSScriptRoot\..\..\_modules\Images" -Force

$saveImageParams = @{
    Grid        = $grid
    FileName    = "$PSScriptRoot\Temp\000.png"
    TrueColour  = [System.Drawing.ColorTranslator]::FromHtml('#DEAA79')
    FalseColour = [System.Drawing.ColorTranslator]::FromHtml('#659287')
}
SaveBitGridToBitmap @saveImageParams

1..$Steps | ForEach-Object {
    $FileName = "$PSScriptRoot\Temp\$('{0:D3}' -f $_).png"
    $newGrid = [bool[, ]]::new($gridSize, $gridSize)

    for ($y = 0; $y -lt $grid.GetLength(0); $y++) {
        for ($x = 0; $x -lt $grid.GetLength(1); $x++) {
            $NumActiveNeighbours = Get-NumTrueNeighbours -Grid $grid -X $x -Y $y
            if ($grid[$y, $x]) {
                # Light is on
                if ($NumActiveNeighbours -eq 2 -or 
                    $NumActiveNeighbours -eq 3) {
                    $newGrid[$y, $x] = $true
                }
            } else {
                # Light is off
                if ($NumActiveNeighbours -eq 3) {
                    $newGrid[$y, $x] = $true
                }
            }
        }
    }
    $grid = $newGrid
    $saveImageParams = @{
        Grid        = $grid
        FileName    = $FileName
        TrueColour  = [System.Drawing.ColorTranslator]::FromHtml('#DEAA79')
        FalseColour = [System.Drawing.ColorTranslator]::FromHtml('#659287')
    }
    SaveBitGridToBitmap @saveImageParams
}

$grid | Where-Object { $_ } | Measure-Object | Select-Object -Expand Count

$gifParams = @{
    InputFolder = "$PSScriptRoot\Temp\"
    OutputGif   = "$PSScriptRoot\part1_visual.gif"
    Framerate   = 5
    Scale       = 20
}
Convert-PngFolderToBWGif @gifParams

Remove-Item "$PSScriptRoot\Temp" -Recurse -Force -Confirm:$false