<#
Next, you should verify the life support rating, which can be determined by
multiplying the oxygen generator rating by the CO2 scrubber rating.

Both the oxygen generator rating and the CO2 scrubber rating are values that can
be found in your diagnostic report - finding them is the tricky part. Both
values are located using a similar process that involves filtering out values
until only one remains. Before searching for either rating value, start with the
full list of binary numbers from your diagnostic report and consider just the
first bit of those numbers. Then:

- Keep only numbers selected by the bit criteria for the type of rating value
  for which you are searching. Discard numbers which do not match the bit
  criteria.
- If you only have one number left, stop; this is the rating value for which you
  are searching.
- Otherwise, repeat the process, considering the next bit to the right.

The bit criteria depends on which type of rating value you want to find:

- To find oxygen generator rating, determine the most common value (0 or 1) in
  the current bit position, and keep only numbers with that bit in that
  position. If 0 and 1 are equally common, keep values with a 1 in the position
  being considered.
- To find CO2 scrubber rating, determine the least common value (0 or 1) in the
  current bit position, and keep only numbers with that bit in that position. If
  0 and 1 are equally common, keep values with a 0 in the position being
  considered.

For example, to determine the oxygen generator rating value using the same
example diagnostic report from above:

- Start with all 12 numbers and consider only the first bit of each number.
  There are more 1 bits (7) than 0 bits (5), so keep only the 7 numbers with a 1
  in the first position: 11110, 10110, 10111, 10101, 11100, 10000, and 11001.
- Then, consider the second bit of the 7 remaining numbers: there are more 0
  bits (4) than 1 bits (3), so keep only the 4 numbers with a 0 in the second
  position: 10110, 10111, 10101, and 10000.
- In the third position, three of the four numbers have a 1, so keep those
  three: 10110, 10111, and 10101.
- In the fourth position, two of the three numbers have a 1, so keep those two:
  10110 and 10111.
- In the fifth position, there are an equal number of 0 bits and 1 bits (one
  each). So, to find the oxygen generator rating, keep the number with a 1 in
  that position: 10111.
- As there is only one number left, stop; the oxygen generator rating is 10111,
  or 23 in decimal.

Then, to determine the CO2 scrubber rating value from the same example above:

- Start again with all 12 numbers and consider only the first bit of each
  number. There are fewer 0 bits (5) than 1 bits (7), so keep only the 5 numbers
  with a 0 in the first position: 00100, 01111, 00111, 00010, and 01010.
- Then, consider the second bit of the 5 remaining numbers: there are fewer 1
  bits (2) than 0 bits (3), so keep only the 2 numbers with a 1 in the second
  position: 01111 and 01010.
- In the third position, there are an equal number of 0 bits and 1 bits (one
  each). So, to find the CO2 scrubber rating, keep the number with a 0 in that
  position: 01010.
- As there is only one number left, stop; the CO2 scrubber rating is 01010, or
  10 in decimal.

Finally, to find the life support rating, multiply the oxygen generator rating
(23) by the CO2 scrubber rating (10) to get 230.

Use the binary numbers in your diagnostic report to calculate the oxygen
generator rating and CO2 scrubber rating, then multiply them together. What is
the life support rating of the submarine? (Be sure to represent your answer in
decimal, not binary.)
#>

# Create independant copies of the list so we can filter each.
$o2SearchList  = [System.Collections.Generic.List[string]]::new()
$co2SearchList = [System.Collections.Generic.List[string]]::new()

Get-Content "$PSScriptRoot\input.txt" | ForEach-Object {
    [void]$o2SearchList.Add($_)
    [void]$co2SearchList.Add($_)
}

# Function which takes a list of numbers and a bit position and returns what the
# most common bit is at that position.
enum SearchResult {
    Zero
    One
    Equal
}

function Get-MostCommonBitAtPosition {
    [OutputType([SearchResult])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [System.Collections.Generic.List[string]]
        $StringList,
        [Parameter(Mandatory, Position = 1)]
        [int]
        $BitPosition
    )
    $oneCount = 0
    $StringList.GetEnumerator() | ForEach-Object {
        if ($PSItem[$BitPosition] -eq '1') {
            $oneCount++
        }
    }
    $halfLength = $StringList.Count / 2
    if ($oneCount -eq $halfLength) {
        [SearchResult]::Equal
    } elseif ($oneCount -gt $halfLength) {
        [SearchResult]::One
    } else {
        [SearchResult]::Zero
    }
}

# Search for the Oxygen Generator Rating
$numBits = $o2SearchList[0].Length
for ($i = 0; $i -lt $numBits; $i++) {
    $mostCommonBit = Get-MostCommonBitAtPosition $o2SearchList $i

    if ($mostCommonBit -eq [SearchResult]::One -or
        $mostCommonBit -eq [SearchResult]::Equal) {
        # Keep all results where 1 is the $i-th bit.
        $wanted = '1'
    } else {
        # Keep all results where 1 is the $i-th bit.
        $wanted = '0'
    }

    for ($j = $o2SearchList.Count - 1; $j -ge 0; $j--) {
        if ($o2SearchList[$j][$i] -ne $wanted) {
            $o2SearchList.RemoveAt($j) | Out-Null
        }
    }
    if ($o2SearchList.Count -le 1) {
        break
    }
}

$o2Rating = [Convert]::ToInt32($o2SearchList[0],2)

# Search for the Carbon Dioxide Generator Rating
$numBits = $co2SearchList[0].Length
for ($i = 0; $i -lt $numBits; $i++) {
    $mostCommonBit = Get-MostCommonBitAtPosition $co2SearchList $i

    if ($mostCommonBit -eq [SearchResult]::One -or
        $mostCommonBit -eq [SearchResult]::Equal) {
        # Keep all results where 1 is the $i-th bit.
        $wanted = '0'
    } else {
        # Keep all results where 1 is the $i-th bit.
        $wanted = '1'
    }

    for ($j = $co2SearchList.Count - 1; $j -ge 0; $j--) {
        if ($co2SearchList[$j][$i] -ne $wanted) {
            $co2SearchList.RemoveAt($j) | Out-Null
        }
    }
    if ($co2SearchList.Count -le 1) {
        break
    }
}
$co2Rating = [Convert]::ToInt32($co2SearchList[0],2)

$o2Rating * $co2Rating