<#
You flip the instructions over; Santa goes on to point out that this is all just
an implementation of Conway's Game of Life. At least, it was, until you notice
that something's wrong with the grid of lights you bought: four lights, one in
each corner, are stuck on and can't be turned off. The example above will
actually run like this:

Initial state:
##.#.#
...##.
#....#
..#...
#.#..#
####.#

After 1 step:
#.##.#
####.#
...##.
......
#...#.
#.####

After 2 steps:
#..#.#
#....#
.#.##.
...##.
.#..##
##.###

After 3 steps:
#...##
####.#
..##.#
......
##....
####.#

After 4 steps:
#.####
#....#
...#..
.##...
#.....
#.#..#

After 5 steps:
##.###
.##..#
.##...
.##...
#.#...
##...#
After 5 steps, this example now has 17 lights on.

In your grid of 100x100 lights, given your initial configuration, but with the
four corners always in the on state, how many lights are on after 100 steps?
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
        # The four corners are stuck on
        if ($y -eq 0 -and ($x -eq 0 -or $x -eq $grid.GetLength(1) - 1) ) {
            $grid[$x, $y] = $true
            continue
        }
        if ($y -eq $grid.GetLength(0) - 1 -and ($x -eq 0 -or $x -eq $grid.GetLength(1) - 1) ) {
            $grid[$x, $y] = $true
            continue
        }
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
            if ($y -eq 0 -and ($x -eq 0 -or $x -eq $grid.GetLength(1) - 1) ) {
                $newGrid[$y, $x] = $true
                continue
            }
            if ($y -eq $grid.GetLength(0) - 1 -and ($x -eq 0 -or $x -eq $grid.GetLength(1) - 1) ) {
                $newGrid[$y, $x] = $true
                continue
            }
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
    OutputGif   = "$PSScriptRoot\part2_visual.gif"
    Framerate   = 5
    Scale       = 20
}
Convert-PngFolderToBWGif @gifParams

Remove-Item "$PSScriptRoot\Temp" -Recurse -Force -Confirm:$false