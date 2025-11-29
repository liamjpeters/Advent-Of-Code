<#
Unfortunately, considering only horizontal and vertical lines doesn't give you
the full picture; you need to also consider diagonal lines.

Because of the limits of the hydrothermal vent mapping system, the lines in your
list will only ever be horizontal, vertical, or a diagonal line at exactly 45
degrees. In other words:

An entry like 1,1 -> 3,3 covers points 1,1, 2,2, and 3,3.
An entry like 9,7 -> 7,9 covers points 9,7, 8,8, and 7,9.

Considering all lines from the above example would now produce the following
diagram:

1.1....11.
.111...2..
..2.1.111.
...1.2.2..
.112313211
...1.2....
..1...1...
.1.....1..
1.......1.
222111....

You still need to determine the number of points where at least two lines
overlap. In the above example, this is still anywhere in the diagram with a 2 or
larger - now a total of 12 points.

Consider all of the lines. At how many points do at least two lines overlap?
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

# Determine max x and y for grid size
$maxX = 0
$maxY = 0
foreach ($line in $lines) {
    $maxX = [Math]::Max([Math]::Max($maxX, $line.Start.X), $line.End.X)
    $maxY = [Math]::Max([Math]::Max($maxY, $line.Start.Y), $line.End.Y)
}

# Initialize grid
$grid = [uint[,]]::new($maxX + 1, $maxY + 1)

# Draw lines on the grid
foreach ($line in $lines) {
    if ($line.Start.X -eq $line.End.X) {
        # Vertical line
        $x = $line.Start.X
        $yStart = [Math]::Min($line.Start.Y, $line.End.Y)
        $yEnd = [Math]::Max($line.Start.Y, $line.End.Y)
        for ($y = $yStart; $y -le $yEnd; $y++) {
            $grid[$x, $y]++
        }
    } elseif ($line.Start.Y -eq $line.End.Y) {
        # Horizontal line
        $y = $line.Start.Y
        $xStart = [Math]::Min($line.Start.X, $line.End.X)
        $xEnd = [Math]::Max($line.Start.X, $line.End.X)
        for ($x = $xStart; $x -le $xEnd; $x++) {
            $grid[$x, $y]++
        }
    } else {
        # Diagonal line at 45 degrees
        $xStep = if ($line.End.X -gt $line.Start.X) { 1 } else { -1 }
        $yStep = if ($line.End.Y -gt $line.Start.Y) { 1 } else { -1 }

        $length = [Math]::Abs($line.End.X - $line.Start.X)
        for ($i = 0; $i -le $length; $i++) {
            $x = $line.Start.X + ($i * $xStep)
            $y = $line.Start.Y + ($i * $yStep)
            $grid[$x, $y]++
        }
    }
}

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
    $pen = [System.Drawing.Pen]::new(
        [System.Drawing.Color]::FromArgb(
            128,
            [System.Drawing.Color]::DarkOrange
        ), 2
    )

    foreach ($line in $lines) {
        $graphics.DrawLine(
            $pen,
            [System.Drawing.Point]::new([int]$line.Start.X, [int]$line.Start.Y),
            [System.Drawing.Point]::new([int]$line.End.X, [int]$line.End.Y)
        )
    }

    $bitmap.Save(
        "$PSScriptRoot\part2.png",
        [System.Drawing.Imaging.ImageFormat]::Png
    )
} catch {
    throw "An error occurred: $($_.Exception.Message)"
} finally {
    if ($pen) { $pen.Dispose() }
    if ($graphics) { $graphics.Dispose() }
    if ($bitmap) { $bitmap.Dispose() }
}