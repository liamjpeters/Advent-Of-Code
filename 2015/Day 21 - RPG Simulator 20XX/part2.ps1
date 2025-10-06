<#
Turns out the shopkeeper is working with the boss, and can persuade you to buy
whatever items he wants. The other rules still apply, and he still only has one
of each item.

What is the most amount of gold you can spend and still lose the fight?
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
    Where-Object PlayerWins -eq $false |
    Sort-Object TotalCost -Descending |
    Select-Object -First 1 -ExpandProperty TotalCost