<#
With your analysis of the manifold complete, you begin fixing the teleporter.
However, as you open the side of the teleporter to replace the broken manifold,
you are surprised to discover that it isn't a classical tachyon manifold - it's
a quantum tachyon manifold.

With a quantum tachyon manifold, only a single tachyon particle is sent through
the manifold. A tachyon particle takes both the left and right path of each
splitter encountered.

Since this is impossible, the manual recommends the many-worlds interpretation
of quantum tachyon splitting: each time a particle reaches a splitter, it's
actually time itself which splits. In one timeline, the particle went left, and
in the other timeline, the particle went right.

To fix the manifold, what you really need to know is the number of timelines
active after a single particle completes all of its possible journeys through
the manifold.

In the above example, there are many timelines. For instance, there's the
timeline where the particle always went left:

.......S.......
.......|.......
......|^.......
......|........
.....|^.^......
.....|.........
....|^.^.^.....
....|..........
...|^.^...^....
...|...........
..|^.^...^.^...
..|............
.|^...^.....^..
.|.............
|^.^.^.^.^...^.
|..............

Or, there's the timeline where the particle alternated going left and right at
each splitter:

.......S.......
.......|.......
......|^.......
......|........
......^|^......
.......|.......
.....^|^.^.....
......|........
....^.^|..^....
.......|.......
...^.^.|.^.^...
.......|.......
..^...^|....^..
.......|.......
.^.^.^|^.^...^.
......|........

Or, there's the timeline where the particle ends up at the same point as the
alternating timeline, but takes a totally different path to get there:

.......S.......
.......|.......
......|^.......
......|........
.....|^.^......
.....|.........
....|^.^.^.....
....|..........
....^|^...^....
.....|.........
...^.^|..^.^...
......|........
..^..|^.....^..
.....|.........
.^.^.^|^.^...^.
......|........

In this example, in total, the particle ends up on 40 different timelines.

Apply the many-worlds interpretation of quantum tachyon splitting to your
manifold diagram. In total, how many different timelines would a single tachyon
particle end up on?
#>

<#
Note(Liam):

I'm thinking about the solution to this problem being a question of how many
"histories" a beam carries. That is, how many different ways can a given point
be reached. The initial beam will be 1. Each time the beam splits it will stay
the same for each new beam.
When beams overlap (when a beam splits onto an existing beam) they will add.

I need to rethink the grid to be a grid of numbers, instead of a grid of
characters.

-1 will be the splitters.
0 will be empty space.
S will start as 1.
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

$grid = [int64[,]]::new($rawInput[0].Length, $rawInput.Length)

# Read the text into the grid
for ($y = 0; $y -lt $rawInput.Length; $y++) {
    for ($x = 0; $x -lt $rawInput[$y].Length; $x++) {
        $grid[$x,$y] = switch ($rawInput[$y][$x]) {
            'S' {
                1
            }
            '^' {
                -1
            }
            default {
                0
            }
        }
    }
}


# Apply the split logic
for ($y = 1; $y -lt $grid.GetLength(1); $y++) {
    for ($x = 0; $x -lt $grid.GetLength(0); $x++) {
        switch ($grid[$x,$y]) {
            -1 {
                # If the thing above me isn't a splitter, split its value left
                # and right (if possible)
                if ($grid[$x,($y-1)] -gt 0) {
                    if ($x -gt 0) {
                        # Split left
                        # Add to the existing value at that position
                        $grid[($x-1),$y] += $grid[$x,($y-1)]
                    }
                    if ($x -lt $grid.GetLength(0) - 1) {
                        # Split left
                        # Add to the existing value at that position
                        $grid[($x+1),$y] += $grid[$x,($y-1)]
                    }
                }
            }
            default {
                # If the thing above me isn't a splitter, carry its value down
                # ensuring that we add to any existing value, as we could be
                # to the right hand side of a just-split mean and be carrying
                # value from that.
                if ($grid[$x,($y-1)] -gt 0) {
                    $grid[$x,$y] += $grid[$x,($y-1)]
                }
            }
        }
    }
}

$y = $grid.GetLength(1)- 1
$sum = 0
for ($x = 0; $x -lt $grid.GetLength(0); $x++) {
    $sum += $grid[$x,$y]
}
$sum

# Find maximum positive value for scaling (ignore -1 splitters)
$maxValue = 0L
for ($y = 0; $y -lt $grid.GetLength(1); $y++) {
    for ($x = 0; $x -lt $grid.GetLength(0); $x++) {
        $v = $grid[$x,$y]
        if ($v -gt $maxValue) { $maxValue = $v }
    }
}

# Ensure System.Drawing is loaded
Add-Type -AssemblyName System.Drawing -ErrorAction Stop

$height = $grid.GetLength(0)
$width = $grid.GetLength(1)

$bitmap = [System.Drawing.Bitmap]::new($width, $height)

# Note(Liam): Copilot suggested log scaling to fit the colors
#             better. It did this bit for me (after I'd done the
#             challenge...)
# Precompute log(max+1) so we can use log scaling
$logMax = if ($maxValue -gt 0) {
    [math]::Log10([double]($maxValue + 1))
} else {
    1.0
}


for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        $v = $grid[$x,$y]

        if ($v -eq -1) {
            # Splitter: black
            $color = [System.Drawing.Color]::Black
        } elseif ($v -le 0) {
            # Empty / no timelines: white (or dark, your choice)
            $color = [System.Drawing.Color]::White
        } else {
            # Note(Liam): Copilot suggested log scaling to fit the colors
            #             better. It did this bit for me (after I'd done the
            #             challenge...)
            # Log scale into [0,1]
            $lv = [math]::Log10([double]($v + 1))
            $t  = $lv / $logMax          # 0–1

            # Map 0→blue, 1→red
            $r = [byte]([math]::Round(255 * $t))
            $g = [byte]([math]::Round(255 * (1 - $t)))
            $b = 0

            $color = [System.Drawing.Color]::FromArgb(255, $r, $g, $b)
        }

        $bitmap.SetPixel($x, $y, $color)
    }
}

# Scale factor (e.g. 4x)
$scale = 16

$srcWidth  = $bitmap.Width
$srcHeight = $bitmap.Height

$dstWidth  = $srcWidth  * $scale
$dstHeight = $srcHeight * $scale

$scaledBitmap = [System.Drawing.Bitmap]::new($dstWidth, $dstHeight)
$g = [System.Drawing.Graphics]::FromImage($scaledBitmap)

# Keep pixels crisp
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::Half

$g.DrawImage($bitmap, 0, 0, $dstWidth, $dstHeight)
$g.Dispose()

$scaledBitmap.Save(
    "$PSScriptRoot\part2.png",
    [System.Drawing.Imaging.ImageFormat]::Png
)
$scaledBitmap.Dispose()
$bitmap.Dispose()