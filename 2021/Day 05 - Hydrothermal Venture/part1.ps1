<#
You come across a field of hydrothermal vents on the ocean floor! These vents
constantly produce large, opaque clouds, so it would be best to avoid them if
possible.

They tend to form in lines; the submarine helpfully produces a list of nearby
lines of vents (your puzzle input) for you to review. For example:

0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2

Each line of vents is given as a line segment in the format x1,y1 -> x2,y2 where
x1,y1 are the coordinates of one end the line segment and x2,y2 are the
coordinates of the other end. These line segments include the points at both
ends. In other words:

- An entry like 1,1 -> 1,3 covers points 1,1, 1,2, and 1,3.
- An entry like 9,7 -> 7,7 covers points 9,7, 8,7, and 7,7.

For now, only consider horizontal and vertical lines: lines where either x1 = x2
or y1 = y2.

So, the horizontal and vertical lines from the above list would produce the
following diagram:

.......1..
..1....1..
..1....1..
.......1..
.112111211
..........
..........
..........
..........
222111....

In this diagram, the top left corner is 0,0 and the bottom right corner is 9,9.
Each position is shown as the number of lines which cover that point or . if no
line covers that point. The top-left pair of 1s, for example, comes from
2,2 -> 2,1; the very bottom row is formed by the overlapping lines 0,9 -> 5,9
and 0,9 -> 2,9.

To avoid the most dangerous areas, you need to determine the number of points
where at least two lines overlap. In the above example, this is anywhere in the
diagram with a 2 or larger - a total of 5 points.

Consider only horizontal and vertical lines. At how many points do at least two
lines overlap?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

# A class representing a single 2D point
class Point {
    [int] $X
    [int] $Y

    Point([int] $x, [int] $y) {
        $this.X = $x
        $this.Y = $y
    }

    [string] ToString() {
        return "$($this.X),$($this.Y)"
    }
}

# A class representing a line segment defined by two Points
class Line {
    [Point] $Start
    [Point] $End

    Line([Point] $start, [Point] $end) {
        $this.Start = $start
        $this.End = $end
    }

    [bool] IsHorizontalOrVertical() {
        return $this.Start.X -eq $this.End.X -or $this.Start.Y -eq $this.End.Y
    }

    [string] ToString() {
        return "$($this.Start) -> $($this.End)"
    }
}

# Parsing input into Line objects
$lines = @()
foreach ($line in $rawInput) {
    $parts = $line -split ' -> '
    $startParts = $parts[0] -split ','
    $endParts = $parts[1] -split ','

    $startPoint = [Point]::new([int]$startParts[0], [int]$startParts[1])
    $endPoint = [Point]::new([int]$endParts[0], [int]$endParts[1])

    $lines += [Line]::new($startPoint, $endPoint)
}

$horizontalOrVerticalLines = $lines | Where-Object {
    $_.IsHorizontalOrVertical()
}

# Determine max x and y for grid size
$maxX = 0
$maxY = 0
foreach ($line in $horizontalOrVerticalLines) {
    $maxX = [Math]::Max([Math]::Max($maxX, $line.Start.X), $line.End.X)
    $maxY = [Math]::Max([Math]::Max($maxY, $line.Start.Y), $line.End.Y)
}

# Initialize grid
$grid = [uint[,]]::new($maxX + 1, $maxY + 1)

# Draw lines on the grid
foreach ($line in $horizontalOrVerticalLines) {
    if ($line.Start.X -eq $line.End.X) {
        # Vertical line
        $x = $line.Start.X
        $yStart = [Math]::Min($line.Start.Y, $line.End.Y)
        $yEnd = [Math]::Max($line.Start.Y, $line.End.Y)
        for ($y = $yStart; $y -le $yEnd; $y++) {
            $grid[$x, $y]++
        }
    } else {
        # Horizontal line
        $y = $line.Start.Y
        $xStart = [Math]::Min($line.Start.X, $line.End.X)
        $xEnd = [Math]::Max($line.Start.X, $line.End.X)
        for ($x = $xStart; $x -le $xEnd; $x++) {
            $grid[$x, $y]++
        }
    }
}

# Get all the locations where at least two lines overlap
$grid.GetEnumerator() |
    Where-Object { $_ -ge 2 } |
    Measure-Object |
    Select-Object -ExpandProperty Count

# Save a bitmap of the grid with lines drawn
try {
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop

    # Create a new Bitmap object
    $bitmap = [System.Drawing.Bitmap]::new(
        [int]$grid.GetLength(0),
        [int]$grid.GetLength(1)
    )

    # Create a Graphics object from the bitmap to draw on it
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

    # Set the background color
    $graphics.Clear([System.Drawing.Color]::Black)

    # Define the pen (Color, Width)
    # Have a little transparency so overlapping lines show up brighter
    $pen = [System.Drawing.Pen]::new(
        [System.Drawing.Color]::FromArgb(
            128,
            [System.Drawing.Color]::DarkOrange
        ), 2
    )
    foreach ($line in $horizontalOrVerticalLines) {
        $graphics.DrawLine(
            $pen,
            [System.Drawing.Point]::new([int]$line.Start.X, [int]$line.Start.Y),
            [System.Drawing.Point]::new([int]$line.End.X, [int]$line.End.Y)
        )
    }

    $bitmap.Save(
        "$PSScriptRoot\part1.png",
        [System.Drawing.Imaging.ImageFormat]::Png
    )
} catch {
    throw "An error occurred: $($_.Exception.Message)"
} finally {
    if ($pen) { $pen.Dispose() }
    if ($graphics) { $graphics.Dispose() }
    if ($bitmap) { $bitmap.Dispose() }
}