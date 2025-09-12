<#
You just finish implementing your winning light pattern when you realize you
mistranslated Santa's message from Ancient Nordic Elvish.

The light grid you bought actually has individual brightness controls; each
light can have a brightness of zero or more. The lights all start at zero.

The phrase turn on actually means that you should increase the brightness of
those lights by 1.

The phrase turn off actually means that you should decrease the brightness of
those lights by 1, to a minimum of zero.

The phrase toggle actually means that you should increase the brightness of
those lights by 2.

What is the total brightness of all lights combined after following Santa's
instructions?

For example:

- turn on 0,0 through 0,0 would increase the total brightness by 1.
- toggle 0,0 through 999,999 would increase the total brightness by 2000000.
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

# Create the array of bools. They're 0 ($false) initialised
$grid = [int[,]]::new(1000,1000)

# Read the instructions and follow what they say to do
foreach ($line in $rawInput) {
    # Instructions are in the format
    # turn on 931,331 through 939,812
    # Parse with regex.
    $Pattern = '^(turn on|turn off|toggle)\s+(\d+),(\d+)\s+through\s+(\d+),(\d+)$'
    $match = [regex]::Match($line, $pattern)

    # We should always match, but if we don't - warn and exit.
    if (-not $match.Success) {
        Write-Warning "Line not in expected format: '$line'"
        exit
    }

    # Gather the required variables
    $instruction = $match.Groups[1].Value
    $x1 = [int]$match.Groups[2].Value
    $y1 = [int]$match.Groups[3].Value
    $x2 = [int]$match.Groups[4].Value
    $y2 = [int]$match.Groups[5].Value

    switch ($instruction) {
        'toggle' {
            for ($y = $y1; $y -le $y2; $y++) {
                for ($x = $x1; $x -le $x2; $x++) {
                    $grid[$y, $x] += 2
                }
            }
        }
        'turn on' {
            for ($y = $y1; $y -le $y2; $y++) {
                for ($x = $x1; $x -le $x2; $x++) {
                    $grid[$y, $x] += 1
                }
            }
        }
        'turn off' {
            for ($y = $y1; $y -le $y2; $y++) {
                for ($x = $x1; $x -le $x2; $x++) {
                    $grid[$y, $x] = [Math]::Max(0, $grid[$y, $x] - 1)
                }
            }
        }
        default {
            Write-Warning "Unknown instruction: '$instruction'"
            exit
        }
    }
}
($grid | Measure-Object -Sum).Sum

# Drawing the output for fun
Add-Type -AssemblyName System.Drawing

$bitmap = New-Object System.Drawing.Bitmap(1000, 1000)
$rows = $grid.GetLength(0)
$cols = $grid.GetLength(1)

$maxValue = ($grid | Measure-Object -Maximum).Maximum
# Loop through the grid and set the pixel color
for ($y = 0; $y -lt $rows; $y++) {
    for ($x = 0; $x -lt $cols; $x++) {
        # Get the integer value from the grid
        $gridValue = $grid[$x, $y]

        # Calculate the grayscale shade (0-255)
        # Using [math]::Round ensures the value is a whole number
        $greyscaleShade = [math]::Round(($gridValue / $maxValue) * 255)

        # Create a new Color object with the same value for R, G, and B
        $greyscaleColor = [System.Drawing.Color]::FromArgb($greyscaleShade, $greyscaleShade, $greyscaleShade)

        # Set the pixel color on the bitmap
        $bitmap.SetPixel($x, $y, $greyscaleColor)
    }
}
$bitmap.Save(
    "$PSScriptRoot\part2_output.png",
    [System.Drawing.Imaging.ImageFormat]::Png
)