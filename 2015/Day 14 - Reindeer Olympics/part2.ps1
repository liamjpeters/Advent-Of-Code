<#
Seeing how reindeer move in bursts, Santa decides he's not pleased with the old
scoring system.

Instead, at the end of each second, he awards one point to the reindeer
currently in the lead. (If there are multiple reindeer tied for the lead, they
each get one point.) He keeps the traditional 2503 second time limit, of course,
as doing otherwise would be entirely ridiculous.

Given the example reindeer from above, after the first second, Dancer is in the
lead and gets one point. He stays in the lead until several seconds into Comet's
second burst: after the 140th second, Comet pulls into the lead and gets his
first point. Of course, since Dancer had been in the lead for the 139 seconds
before that, he has accumulated 139 points by the 140th second.

After the 1000th second, Dancer has accumulated 689 points, while poor Comet,
our old champion, only has 312. So, with the new scoring system, Dancer would
win (if the race ended at 1000 seconds).

Again given the descriptions of each reindeer (in your puzzle input), after
exactly 2503 seconds, how many points does the winning reindeer have?
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
            Points = 0
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
    # What's the highest score?
    $leadDistance = $reindeer |
        Measure-Object -Property DistanceCovered -Maximum |
        Select-Object -ExpandProperty Maximum

    foreach ($racer in $reindeer) {
        if ($racer.DistanceCovered -eq $leadDistance) {
            $racer.Points++
        }
    }
}

$reindeer | 
    Sort-Object Points -Descending | 
    Select-Object -First 1 -ExpandProperty Points
