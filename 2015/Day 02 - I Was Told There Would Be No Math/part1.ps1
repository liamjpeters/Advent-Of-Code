<#
The elves are running low on wrapping paper, and so they need to submit an order
for more. They have a list of the dimensions (length l, width w, and height h)
of each present, and only want to order exactly as much as they need.

Fortunately, every present is a box (a perfect right rectangular prism), which
makes calculating the required wrapping paper for each gift a little easier:
find the surface area of the box, which is 2*l*w + 2*w*h + 2*h*l. The elves also
need a little extra paper for each present: the area of the smallest side.

For example:

- A present with dimensions 2x3x4 requires 2*6 + 2*12 + 2*8 = 52 square feet of
  wrapping paper plus 6 square feet of slack, for a total of 58 square feet.
- A present with dimensions 1x1x10 requires 2*1 + 2*10 + 2*10 = 42 square feet
  of wrapping paper plus 1 square foot of slack, for a total of 43 square feet.

All numbers in the elves' list are in feet. How many total square feet of
wrapping paper should they order?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

$runningTotal = 0
foreach ($line in $rawInput) {
    # Input is in the form '3x11x24' L x W x H
    $length,$width,$height = $line.Split('x') | ForEach-Object {[int]$_}

    # Define the 3 sides
    $side1 = $length * $width
    $side2 = $width * $height
    $side3 = $height * $length

    # Find the smallest side, Side Smallest
    $shortestSide = $side1,$side2,$side3 |
        Measure-Object -Minimum |
        Select-Object -ExpandProperty Minimum

    # Keep a running total
    $runningTotal += 2 * ($side1 + $side2 + $side3) + $shortestSide
}
$runningTotal