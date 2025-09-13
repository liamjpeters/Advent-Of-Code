<#
This year is the Reindeer Olympics! Reindeer can fly at high speeds, but must
rest occasionally to recover their energy. Santa would like to know which of his
reindeer is fastest, and so he has them race.

Reindeer can only either be flying (always at their top speed) or resting (not
moving at all), and always spend whole seconds in either state.

For example, suppose you have the following Reindeer:

- Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
- Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.

After one second, Comet has gone 14 km, while Dancer has gone 16 km. After ten
seconds, Comet has gone 140 km, while Dancer has gone 160 km. On the eleventh
second, Comet begins resting (staying at 140 km), and Dancer continues on for a
total distance of 176 km. On the 12th second, both reindeer are resting. They
continue to rest until the 138th second, when Comet flies for another ten
seconds. On the 174th second, Dancer flies for another 11 seconds.

In this example, after the 1000th second, both reindeer are resting, and Comet
is in the lead at 1120 km (poor Dancer has only gotten 1056 km by that point).
So, in this situation, Comet would win (if the race ended at 1000 seconds).

Given the descriptions of each reindeer (in your puzzle input), after exactly
2503 seconds, what distance has the winning reindeer traveled?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

# Regex for parsing the lines
$pattern = '^(?<name>\w+) can fly (?<speed>\d+) km/s for (?<duration>\d+) seconds, but then must rest for (?<rest>\d+) seconds.$'

$reindeer = @()

foreach ($line in $rawInput) {
    if ($line -match $pattern) {
        $reindeer += [PSCustomObject]@{
            Name     = $Matches['name']
            Speed    = [int]$Matches['speed']
            Duration = [int]$Matches['duration']
            Rest     = [int]$Matches['rest']
            State = 'Running' # Or 'Resting'
            TimeInState = 0
            DistanceCovered = 0
        }
    } else {
        Write-Error "Parse Error - line does not match patter: '$($line)'"
        exit
    }
}

# Step through the race and update the reindeer
$raceTime = 2503
1..$raceTime | ForEach-Object {
    # silly reindeer being self-pluralising
    :racerLoop foreach ($racer in $reindeer) {
        if ($racer.State -eq 'Running') {
            if ($racer.TimeInState -ge $racer.Duration) {
                # Switch to resting
                $racer.State = 'Resting'
                $racer.TimeInState = 1
                continue racerLoop
            }
            $racer.TimeInState++
            $racer.DistanceCovered += $racer.Speed
        } elseif ($racer.State -eq 'Resting') {
            if ($racer.TimeInState -ge $racer.Rest) {
                # Switch to resting
                $racer.State = 'Running'
                $racer.TimeInState = 1
                $racer.DistanceCovered += $racer.Speed
                continue racerLoop
            }
            $racer.TimeInState++
        } else {
            Write-Error "Error - Unknown racer state: $($racer.State)"
            exit
        }
    }
}

$reindeer | 
    Sort-Object DistanceCovered -Descending | 
    Select-Object -First 1 -ExpandProperty DistanceCovered