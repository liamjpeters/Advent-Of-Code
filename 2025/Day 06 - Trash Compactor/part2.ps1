<#
The big cephalopods come back to check on how things are going. When they see
that your grand total doesn't match the one expected by the worksheet, they
realize they forgot to explain how to read cephalopod math.

Cephalopod math is written right-to-left in columns. Each number is given in its
own column, with the most significant digit at the top and the least significant
digit at the bottom. (Problems are still separated with a column consisting only
of spaces, and the symbol at the bottom of the problem is still the operator to
use.)

Here's the example worksheet again:

123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  

Reading the problems right-to-left one column at a time, the problems are now
quite different:

The rightmost problem is 4 + 431 + 623 = 1058
The second problem from the right is 175 * 581 * 32 = 3253600
The third problem from the right is 8 + 248 + 369 = 625
Finally, the leftmost problem is 356 * 24 * 1 = 8544

Now, the grand total is 1058 + 3253600 + 625 + 8544 = 3263827.

Solve the problems on the math worksheet again. What is the grand total found by
adding together all of the answers to the individual problems?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

# Store the grid as a 2D array of chars
$grid = [char[,]]::new($rawInput[0].Length, $rawInput.Length)

# Read the text into the grid
for ($y = 0; $y -lt $rawInput.Length; $y++) {
    for ($x = 0; $x -lt $rawInput[$y].Length; $x++) {
        $grid[$x,$y] = $rawInput[$y][$x]
    }
}

$total = 0
$numbers = @()

# From right to left
:xLoop for ($x = $grid.GetLength(0) - 1; $x -ge 0 ; $x--) {

    # Build the current number for this column
    $number = [System.Text.StringBuilder]::new()
    :yloop for ($y = 0; $y -lt $grid.GetLength(1); $y++) {
        # Skip any spaces
        if ($grid[$x,$y] -eq ' ') {
            continue yLoop
        }

        # If we hit an operator, perform the operation and then rezero the
        # number list and move to the next column
        if ($grid[$x,$y] -eq '+') {
            # Perform the + operation
            $numbers += [int]$number.ToString()
            $total += ($numbers | Measure-Object -Sum).Sum
            $numbers = @()
            continue xLoop
        }
        if ($grid[$x,$y] -eq '*') {
            # Perform the * operation
            $numbers += [int]$number.ToString()
            $product = 1
            foreach ($n in $numbers) {
                $product *= $n
            }
            $total += $product
            $numbers = @()
            continue xLoop
        }
        # Otherwise, append the digit to the current number
        $number.Append($grid[$x,$y]) | Out-Null
    }
    if ($number.Length -eq 0) {
        # If we reach here, we hit a full column of spaces - skip it
        continue xLoop
    }
    # Otherwise, we hit the end of the column without an operator - store the
    # number for the next iteration
    $numbers += [int]$number.ToString()
}

# Emit the total
$total