<#
You're already almost 1.5km (almost a mile) below the surface of the ocean,
already so deep that you can't see any sunlight. What you can see, however, is a
giant squid that has attached itself to the outside of your submarine.

Maybe it wants to play bingo?

Bingo is played on a set of boards each consisting of a 5x5 grid of numbers.
Numbers are chosen at random, and the chosen number is marked on all boards on
which it appears. (Numbers may not appear on all boards.) If all numbers in any
row or any column of a board are marked, that board wins. (Diagonals don't
count.)

The submarine has a bingo subsystem to help passengers (currently, you and the
giant squid) pass the time. It automatically generates a random order in which
to draw numbers and a random set of boards (your puzzle input). For example:

7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7

After the first five numbers are drawn (7, 4, 9, 5, and 11), there are no
winners, but the boards are marked as follows (shown here adjacent to each other
to save space):

22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
 8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
 6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
 1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

After the next six numbers are drawn (17, 23, 2, 0, 14, and 21), there are still
no winners:

22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
 8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
 6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
 1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

Finally, 24 is drawn:

22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
 8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
 6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
 1 12 20 15 19        14 21 16 12  6         2  0 12  3  7

At this point, the third board wins because it has at least one complete row or
column of marked numbers (in this case, the entire top row is marked: 14 21 17
24 4).

The score of the winning board can now be calculated. Start by finding the sum
of all unmarked numbers on that board; in this case, the sum is 188. Then,
multiply that sum by the number that was just called when the board won, 24, to
get the final score, 188 * 24 = 4512.

To guarantee victory against the giant squid, figure out which board will win
first. What will your final score be if you choose that board?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

# The first line is the comma separated numbers to be called
$calledNumbers = $rawInput[0] -split ',' | ForEach-Object { [int]$_ }

class BingoBoard {

    # Keep track of the numbers on the boards and whether they are marked or not
    [int[,]] $Board
    [bool[,]] $Marked

    # Constructor to initialize the board from 5 lines of input
    #     14  21  17  24   4
    #     10  16  15   9  19
    #     18   8  23  26  20
    #     22  11  13   6   5
    #      2   0  12   3   7
    BingoBoard([string[]] $lines) {
        $this.Board = [int[,]]::new(5,5)
        $this.Marked = [bool[,]]::new(5,5)
        for ($i = 0; $i -lt 5; $i++) {
            $numbers = $lines[$i] -split '\s+' |
                Where-Object { $_ -ne '' } | 
                ForEach-Object { [int]$_ }
            for ($j = 0; $j -lt 5; $j++) {
                $this.Board[$i,$j] = $numbers[$j]
                $this.Marked[$i,$j] = $false
            }
        }
    }

    # Mark a number if it exists on the board
    [void] MarkNumber([int] $number) {
        for ($i = 0; $i -lt 5; $i++) {
            for ($j = 0; $j -lt 5; $j++) {
                if ($this.Board[$i,$j] -eq $number) {
                    $this.Marked[$i,$j] = $true
                }
            }
        }
    }

    # Check if any row is completely marked
    [bool] CheckRows() {
        for ($i = 0; $i -lt 5; $i++) {
            $rowComplete = $true
            for ($j = 0; $j -lt 5; $j++) {
                if (-not $this.Marked[$i,$j]) {
                    $rowComplete = $false
                    break
                }
            }
            if ($rowComplete) {
                return $true
            }
        }
        return $false
    }

    # Check if any column is completely marked
    [bool] CheckColumns() {
        for ($j = 0; $j -lt 5; $j++) {
            $colComplete = $true
            for ($i = 0; $i -lt 5; $i++) {
                if (-not $this.Marked[$i,$j]) {
                    $colComplete = $false
                    break
                }
            }
            if ($colComplete) {
                return $true
            }
        }
        return $false
    }

    # Check if the board is a winner (any row or column completely marked)
    [bool] IsWinner() {
        return $this.CheckRows() -or $this.CheckColumns()
    }

    [int] SumUnmarked() {
        $sum = 0
        for ($i = 0; $i -lt 5; $i++) {
            for ($j = 0; $j -lt 5; $j++) {
                if (-not $this.Marked[$i,$j]) {
                    $sum += $this.Board[$i,$j]
                }
            }
        }
        return $sum
    }

    [string] ToString() {
        $wb    = "`e[37;40m"  # white text on black background
        $reset = "`e[0m"
        $builder = [System.Text.StringBuilder]::new()
        for ($i = 0; $i -lt 5; $i++) {
            for ($j = 0; $j -lt 5; $j++) {
                if ($this.Marked[$i,$j]) {
                    $builder.Append("$wb") | Out-Null
                }
                $builder.AppendFormat("{0,3} ", $this.Board[$i,$j]) | Out-Null
                if ($this.Marked[$i,$j]) {
                    $builder.Append("$reset") | Out-Null
                }
            }
            $builder.AppendLine() | Out-Null
        }
        return $builder.ToString()
    }

    # Print the board with marked numbers highlighted
    [void] Print() {
        $wb    = "`e[37;40m"  # white text on black background
        $reset = "`e[0m"
        for ($i = 0; $i -lt 5; $i++) {
            for ($j = 0; $j -lt 5; $j++) {
                if ($this.Marked[$i,$j]) {
                    $fg = 'White'
                    $bg = 'Green'
                } else {
                    $fg = 'Black'
                    $bg = 'White'
                }
                Write-Host -NoNewline ("{0,3} " -f $this.Board[$i,$j]) -ForegroundColor $fg -BackgroundColor $bg
            }
            Write-Host ""
        }
    }
}

# Parse bingo boards from the input into BingoBoard objects
$bingoBoards = @()
for ($i = 1; $i -lt $rawInput.Length; $i++) {
    if ($rawInput[$i] -eq '') {
        continue
    }
    $boardLines = @($rawInput[$i])
    for ($j = 1; $j -lt 5; $j++) {
        $boardLines += $rawInput[$i + $j]
    }
    $bingoBoards += [BingoBoard]::new($boardLines)
    $i += 4
}

# Simulate the bingo game
foreach ($number in $calledNumbers) {
    foreach ($board in $bingoBoards) {
        $board.MarkNumber($number)
        if ($board.IsWinner()) {
            Write-Host "Winning number: $number"
            Write-Host "Winning board:"
            $board.Print()
            $sumUnmarked = $board.SumUnmarked()
            Write-Host "Sum of unmarked numbers: $sumUnmarked"
            $finalScore = $sumUnmarked * $number
            Write-Host "Final score (sum * winning number): $finalScore"
            break 2
        }
    }
}