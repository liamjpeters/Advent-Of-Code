<#
The elves are also running low on ribbon. Ribbon is all the same width, so they
only have to worry about the length they need to order, which they would again
like to be exact.

The ribbon required to wrap a present is the shortest distance around its sides,
or the smallest perimeter of any one face. Each present also requires a bow made
out of ribbon as well; the feet of ribbon required for the perfect bow is equal
to the cubic feet of volume of the present. Don't ask how they tie the bow,
though; they'll never tell.

For example:

- A present with dimensions 2x3x4 requires 2+2+3+3 = 10 feet of ribbon to wrap
  the present plus 2*3*4 = 24 feet of ribbon for the bow, for a total of 34
  feet.
- A present with dimensions 1x1x10 requires 1+1+1+1 = 4 feet of ribbon to wrap
  the present plus 1*1*10 = 10 feet of ribbon for the bow, for a total of 14
  feet.

How many total feet of ribbon should they order?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

$runningTotal = 0
foreach ($line in $rawInput) {
    # Input is in the form '3x11x24' L x W x H
    $length,$width,$height = $line.Split('x') | ForEach-Object {[int]$_}

    # Calculate the volume for the bow
    $volume = $length * $width * $height

    # Determine the 2 shortest dimensions
    $dim1, $dim2 = $length,$width,$height | Sort-Object | Select-Object -First 2

    # Keep a running total
    $runningTotal += 2 * $dim1 + 2 * $dim2 + $volume
}
$runningTotal