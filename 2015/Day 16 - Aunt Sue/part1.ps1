<#
Your Aunt Sue has given you a wonderful gift, and you'd like to send her a thank
you card. However, there's a small problem: she signed it "From, Aunt Sue".

You have 500 Aunts named "Sue".

So, to avoid sending the card to the wrong person, you need to figure out which
Aunt Sue (which you conveniently number 1 to 500, for sanity) gave you the gift.
You open the present and, as luck would have it, good ol' Aunt Sue got you a My
First Crime Scene Analysis Machine! Just what you wanted. Or needed, as the case
may be.

The My First Crime Scene Analysis Machine (MFCSAM for short) can detect a few
specific compounds in a given sample, as well as how many distinct kinds of
those compounds there are. According to the instructions, these are what the
MFCSAM can detect:

- children, by human DNA age analysis.
- cats. It doesn't differentiate individual breeds.
- Several seemingly random breeds of dog: samoyeds, pomeranians, akitas, and
  vizslas.
- goldfish. No other kinds of fish.
- trees, all in one group.
- cars, presumably by exhaust or gasoline or something.
- perfumes, which is handy, since many of your Aunts Sue wear a few kinds.

In fact, many of your Aunts Sue have many of these. You put the wrapping from
the gift into the MFCSAM. It beeps inquisitively at you a few times and then
prints out a message on ticker tape:

children: 3
cats: 7
samoyeds: 2
pomeranians: 3
akitas: 0
vizslas: 0
goldfish: 5
trees: 3
cars: 2
perfumes: 1

You make a list of the things you can remember about each Aunt Sue. Things
missing from your list aren't zero - you simply don't remember the value.

What is the number of the Sue that got you the gift?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

# Parse the sues and their props
$propPattern = '(?<Prop>\w+): (?<Value>\d+)'
$suePattern = '^Sue (?<SueNumber>\d+): (?<Props>.+)$'

$allSues = @()
foreach ($line in $rawInput) {
    if ($line -match $suePattern) {
        $sueNum = $matches['SueNumber']
        $props = @{}
        foreach ($propMatch in [regex]::Matches($matches['Props'], $propPattern)) {
            $props[$propMatch.Groups['Prop'].Value] = [int]$propMatch.Groups['Value'].Value
        }
        $allSues += [PSCustomObject]@{
            Number = $sueNum
            Props = $props
        }
    }
}


# Search the sues
$foundSue = $allSues | Where-Object {
    ($_.Props['children'] -eq $null -or $_.Props['children'] -eq 3) -and
    ($_.Props['cats'] -eq $null -or $_.Props['cats'] -eq 7) -and
    ($_.Props['samoyeds'] -eq $null -or $_.Props['samoyeds'] -eq 2) -and
    ($_.Props['pomeranians'] -eq $null -or $_.Props['pomeranians'] -eq 3) -and
    ($_.Props['akitas'] -eq $null -or $_.Props['akitas'] -eq 0) -and
    ($_.Props['vizslas'] -eq $null -or $_.Props['vizslas'] -eq 0) -and
    ($_.Props['goldfish'] -eq $null -or $_.Props['goldfish'] -eq 5) -and
    ($_.Props['trees'] -eq $null -or $_.Props['trees'] -eq 3) -and
    ($_.Props['cars'] -eq $null -or $_.Props['cars'] -eq 2) -and
    ($_.Props['perfumes'] -eq $null -or $_.Props['perfumes'] -eq 1)
}

# If we got back more than 1 sue - something went wrong
if ($foundSue.Count -ne 1) {
    Write-Error "Found too many sues"
    exit
}

# Write our sue's number
$foundSue.Number