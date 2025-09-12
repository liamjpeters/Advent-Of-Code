<#
Because your neighbors keep defeating you in the holiday house decorating
contest year after year, you've decided to deploy one million lights in a
1000x1000 grid.

Furthermore, because you've been especially nice this year, Santa has mailed you
instructions on how to display the ideal lighting configuration.

Lights in your grid are numbered from 0 to 999 in each direction; the lights at
each corner are at 0,0, 0,999, 999,999, and 999,0. The instructions include
whether to turn on, turn off, or toggle various inclusive ranges given as
coordinate pairs. Each coordinate pair represents opposite corners of a
rectangle, inclusive; a coordinate pair like 0,0 through 2,2 therefore refers to
9 lights in a 3x3 square. The lights all start turned off.

To defeat your neighbors this year, all you have to do is set up your lights by
doing the instructions Santa sent you in order.

For example:

- turn on 0,0 through 999,999 would turn on (or leave on) every light.
- toggle 0,0 through 999,0 would toggle the first line of 1000 lights, turning
  off the ones that were on, and turning on the ones that were off.
- turn off 499,499 through 500,500 would turn off (or leave off) the middle four
  lights.

After following the instructions, how many lights are lit?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

# Create the array of bools. They're 0 ($false) initialised
$grid = [bool[,]]::new(1000,1000)

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
                    $grid[$y, $x] = -not $grid[$y, $x]
                }
            }
        }
        'turn on' {
            for ($y = $y1; $y -le $y2; $y++) {
                for ($x = $x1; $x -le $x2; $x++) {
                    $grid[$y, $x] = $true
                }
            }
        }
        'turn off' {
            for ($y = $y1; $y -le $y2; $y++) {
                for ($x = $x1; $x -le $x2; $x++) {
                    $grid[$y, $x] = $false
                }
            }
        }
        default {
            Write-Warning "Unknown instruction: '$instruction'"
            exit
        }
    }
}
($grid | Where-Object { $_ -eq $true } | Measure-Object).Count

## Drawing the output for fun
# Add-Type -AssemblyName System.Drawing

# $bitmap = New-Object System.Drawing.Bitmap(1000, 1000)
# $black = [System.Drawing.Color]::Black
# $white = [System.Drawing.Color]::White
# $rows = $grid.GetLength(0)
# $cols = $grid.GetLength(1)
# # Loop through the grid and set the pixel color
# for ($y = 0; $y -lt $rows; $y++) {
#     for ($x = 0; $x -lt $cols; $x++) {
#         # Check the boolean value at the current grid coordinate
#         if ($grid[$x, $y] -eq $true) {
#             # If true, set the pixel to black
#             $bitmap.SetPixel($x, $y, $black)
#         } else {
#             # If false, set the pixel to white
#             $bitmap.SetPixel($x, $y, $white)
#         }
#     }
# }
# $bitmap.Save(
#     "$PSScriptRoot\part1_output.png",
#     [System.Drawing.Imaging.ImageFormat]::Png
# )