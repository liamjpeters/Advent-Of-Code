<#
Little Henry Case got a new video game for Christmas. It's an RPG, and he's
stuck on a boss. He needs to know what equipment to buy at the shop. He hands
you the controller.

In this game, the player (you) and the enemy (the boss) take turns attacking.
The player always goes first. Each attack reduces the opponent's hit points by
at least 1. The first character at or below 0 hit points loses.

Damage dealt by an attacker each turn is equal to the attacker's damage score
minus the defender's armor score. An attacker always does at least 1 damage. So,
if the attacker has a damage score of 8, and the defender has an armor score of
3, the defender loses 5 hit points. If the defender had an armor score of 300,
the defender would still lose 1 hit point.

Your damage score and armor score both start at zero. They can be increased by
buying items in exchange for gold. You start with no items and have as much gold
as you need. Your total damage or armor is equal to the sum of those stats from
all of your items. You have 100 hit points.

Here is what the item shop is selling:

Weapons:    Cost  Damage  Armor
Dagger        8     4       0
Shortsword   10     5       0
Warhammer    25     6       0
Longsword    40     7       0
Greataxe     74     8       0

Armor:      Cost  Damage  Armor
Leather      13     0       1
Chainmail    31     0       2
Splintmail   53     0       3
Bandedmail   75     0       4
Platemail   102     0       5

Rings:      Cost  Damage  Armor
Damage +1    25     1       0
Damage +2    50     2       0
Damage +3   100     3       0
Defense +1   20     0       1
Defense +2   40     0       2
Defense +3   80     0       3

You must buy exactly one weapon; no dual-wielding. Armor is optional, but you
can't use more than one. You can buy 0-2 rings (at most one for each hand). You
must use any items you buy. The shop only has one of each item, so you can't
buy, for example, two rings of Damage +3.

For example, suppose you have 8 hit points, 5 damage, and 5 armor, and that the
boss has 12 hit points, 7 damage, and 2 armor:

The player deals 5-2 = 3 damage; the boss goes down to 9 hit points.
The boss deals 7-5 = 2 damage; the player goes down to 6 hit points.
The player deals 5-2 = 3 damage; the boss goes down to 6 hit points.
The boss deals 7-5 = 2 damage; the player goes down to 4 hit points.
The player deals 5-2 = 3 damage; the boss goes down to 3 hit points.
The boss deals 7-5 = 2 damage; the player goes down to 2 hit points.
The player deals 5-2 = 3 damage; the boss goes down to 0 hit points.

In this scenario, the player wins! (Barely.)

You have 100 hit points. The boss's actual stats are in your puzzle input. What
is the least amount of gold you can spend and still win the fight?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

$weapons = @(
    [PSCustomObject]@{ Name = 'Dagger'; Cost = 8; Damage = 4; Armor = 0 }
    [PSCustomObject]@{ Name = 'Shortsword'; Cost = 10; Damage = 5; Armor = 0 }
    [PSCustomObject]@{ Name = 'Warhammer'; Cost = 25; Damage = 6; Armor = 0 }
    [PSCustomObject]@{ Name = 'Longsword'; Cost = 40; Damage = 7; Armor = 0 }
    [PSCustomObject]@{ Name = 'Greataxe'; Cost = 74; Damage = 8; Armor = 0 }
)

$armors = @(
    [PSCustomObject]@{ Name = 'None'; Cost = 0; Damage = 0; Armor = 0 }
    [PSCustomObject]@{ Name = 'Leather'; Cost = 13; Damage = 0; Armor = 1 }
    [PSCustomObject]@{ Name = 'Chainmail'; Cost = 31; Damage = 0; Armor = 2 }
    [PSCustomObject]@{ Name = 'Splintmail'; Cost = 53; Damage = 0; Armor = 3 }
    [PSCustomObject]@{ Name = 'Bandedmail'; Cost = 75; Damage = 0; Armor = 4 }
    [PSCustomObject]@{ Name = 'Platemail'; Cost = 102; Damage = 0; Armor = 5 }
)

$rings = @(
    [PSCustomObject]@{ Name = 'Damage +1'; Cost = 25; Damage = 1; Armor = 0 }
    [PSCustomObject]@{ Name = 'Damage +2'; Cost = 50; Damage = 2; Armor = 0 }
    [PSCustomObject]@{ Name = 'Damage +3'; Cost = 100; Damage = 3; Armor = 0 }
    [PSCustomObject]@{ Name = 'Defense +1'; Cost = 20; Damage = 0; Armor = 1 }
    [PSCustomObject]@{ Name = 'Defense +2'; Cost = 40; Damage = 0; Armor = 2 }
    [PSCustomObject]@{ Name = 'Defense +3'; Cost = 80; Damage = 0; Armor = 3 }
)

$playerHitPoints = 100

$bossStats = [PSCustomObject]@{
    HitPoints = ($rawInput | Select-String 'Hit Points: (\d+)' | ForEach-Object {
            [int]$_.Matches[0].Groups[1].Value
        })
    Damage    = ($rawInput | Select-String 'Damage: (\d+)' | ForEach-Object {
            [int]$_.Matches[0].Groups[1].Value
        })
    Armor     = ($rawInput | Select-String 'Armor: (\d+)' | ForEach-Object {
            [int]$_.Matches[0].Groups[1].Value
        })
}

# Must buy exactly one weapon, zero or one armor, and zero to two rings

# We can loop over the weapons as we know we need one. Then we can loop over
# the armor as we can have zero or one. Finally, we can loop over the unique
# combinations of rings, which can be zero, one, or two.

# Import combinatorics module for ring combinations (Get-CombinationsWithLimit)
Import-Module "$PSScriptRoot\..\..\_modules\Combinatorics.psm1" -Force
$ringCombos = Get-CombinationsWithLimit -Items $rings -Limit 2

$results = @()

foreach ($weapon in $weapons) {
    foreach ($armor in $armors) {
        foreach ($ringCombo in $ringCombos) {
            $loadout = [PSCustomObject]@{
                Weapon  = $weapon
                Armor   = $armor
                Rings   = $ringCombo.Combination
                Cost    = ($weapon.Cost + $armor.Cost + (
                        $ringCombo.Combination | Measure-Object -Property Cost -Sum
                    ).Sum)
                Damage  = ($weapon.Damage + $armor.Damage + (
                        $ringCombo.Combination | Measure-Object -Property Damage -Sum
                    ).Sum)
                Defence = ($weapon.Armor + $armor.Armor + (
                        $ringCombo.Combination | Measure-Object -Property Armor -Sum
                    ).Sum)
            }

            # Simulate fight
            $playerHP = $playerHitPoints
            $bossHP = $bossStats.HitPoints

            while ($true) {
                # Player attacks first
                $damageToBoss = [Math]::Max(1, $loadout.Damage - $bossStats.Armor)
                $bossHP -= $damageToBoss
                if ($bossHP -le 0) {
                    # Player wins
                    $results += [PSCustomObject]@{
                        PlayerWins = $true
                        TotalCost  = $loadout.Cost
                        Loadout    = $loadout
                    }
                    break
                }

                # Boss attacks
                $damageToPlayer = [Math]::Max(1, $bossStats.Damage - $loadout.Defence)
                $playerHP -= $damageToPlayer
                if ($playerHP -le 0) {
                    # Boss wins
                    $results += [PSCustomObject]@{
                        PlayerWins = $false
                        TotalCost  = $loadout.Cost
                        Loadout    = $loadout
                    }
                    break
                }
            }
        }
    }
}

$results |
    Where-Object PlayerWins -eq $true |
    Sort-Object TotalCost |
    Select-Object -First 1 -ExpandProperty TotalCost