<#
On the other hand, it might be wise to try a different strategy: let the giant
squid win.

You aren't sure how many bingo boards a giant squid could play at once, so
rather than waste time counting its arms, the safe thing to do is to figure out
which board will win last and choose that one. That way, no matter which boards
it picks, it will win for sure.

In the above example, the second board is the last to win, which happens after
13 is eventually called and its middle column is completely marked. If you were
to keep playing until this point, the second board would have a sum of unmarked
numbers equal to 148 for a final score of 148 * 13 = 1924.

Figure out which board will win last. Once it wins, what would its final score
be?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

# The first line is the comma separated numbers to be called
$calledNumbers = $rawInput[0] -split ',' | ForEach-Object { [int]$_ }

class BingoBoard {

    # Keep track of the numbers on the boards and whether they are marked or not
    [int[,]] $Board
    [bool[,]] $Marked

    # Keep track of whether the board has already won and if so what it's final
    # score was
    [bool] $HasWon = $false
    [int] $FinalScore = 0

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

    [void] SetWinner([int] $finalScore) {
        $this.HasWon = $true
        $this.FinalScore = $finalScore
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

$BoardWinnerOrder = @()

# Simulate the bingo game
foreach ($number in $calledNumbers) {
    for ($i = 0; $i -lt $bingoBoards.Count; $i++) {
        $bingoBoards[$i].MarkNumber($number)
        if (-not $bingoBoards[$i].HasWon -and $bingoBoards[$i].IsWinner()) {
            $sumUnmarked = $bingoBoards[$i].SumUnmarked()
            $finalScore = $sumUnmarked * $number
            $bingoBoards[$i].SetWinner($finalScore)
            $BoardWinnerOrder += $i
        }
    }
}

$bingoBoards[$BoardWinnerOrder[-1]].Print()
$bingoBoards[$BoardWinnerOrder[-1]].FinalScore