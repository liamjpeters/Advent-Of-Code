<#

#>

$rawInput = Get-Content "$PSScriptRoot\input.txt" -Raw

# Santa starts at 0,0
$santaX = 0
$santaY = 0
$roboSantaX = 0
$roboSantaY = 0

# Keep a track of all the locations Santa and Robo-Santa have visited and how
# many times
$visitedLocs = @{
    "0,0" = 2
}

foreach ($index in 0..$($rawInput.Length - 1)) {
    $instruction = $rawInput[$index]

    if ($index % 2 -eq 0) {
        # Santa
        switch ($instruction) {
            '^' { $santaY++; break }
            'v' { $santaY--; break }
            '>' { $santaX++; break }
            '<' { $santaX--; break }
            default {
                throw "unknown instruction '$instruction'"
            }
        }
        $key = "$santaX,$santaY"
    } else {
        # Robo-Santa
        switch ($instruction) {
            '^' { $roboSantaY++; break }
            'v' { $roboSantaY--; break }
            '>' { $roboSantaX++; break }
            '<' { $roboSantaX--; break }
            default {
                throw "unknown instruction '$instruction'"
            }
        }
        $key = "$roboSantaX,$roboSantaY"
    }

    # Check if we've been here before and increment the visit count if so
    if ($visitedLocs.ContainsKey($key)) {
        $visitedLocs[$key]++
        continue
    }
    # If not, insert a 1
    $visitedLocs[$key] = 1
}

$visitedLocs.Count