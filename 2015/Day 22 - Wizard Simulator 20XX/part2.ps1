<#
On the next run through the game, you increase the difficulty to hard.

At the start of each player turn (before any other effects apply), you lose 1
hit point. If this brings you to or below 0 hit points, you lose.

With the same starting stats for you and the boss, what is the least amount of
mana you can spend and still win the fight?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt" -Raw

$rawInput = Get-Content "$PSScriptRoot\input.txt"

# Parse boss stats
$bossHP = [int]($rawInput[0] -replace '[^\d]' , '')
$bossDmg = [int]($rawInput[1] -replace '[^\d]' , '')

# Spell definitions
$Spells = @(
    [pscustomobject]@{
        Name   = 'MagicMissile'
        Cost   = 53
        Type   = 'Instant'
        Damage = 4
        Heal   = 0
        Timer  = 0
    }
    [pscustomobject]@{
        Name   = 'Drain'
        Cost   = 73
        Type   = 'Instant'
        Damage = 2
        Heal   = 2
        Timer  = 0
    }
    [pscustomobject]@{
        Name   = 'Shield'
        Cost   = 113
        Type   = 'Effect'
        Damage = 0
        Heal   = 0
        Timer  = 6
    }
    [pscustomobject]@{
        Name   = 'Poison'
        Cost   = 173
        Type   = 'Effect'
        Damage = 0
        Heal   = 0
        Timer  = 6
    }
    [pscustomobject]@{
        Name   = 'Recharge'
        Cost   = 229
        Type   = 'Effect'
        Damage = 0
        Heal   = 0
        Timer  = 5
    }
)

# Hashtable of seen states: key -> lowest mana spent
$seen = @{}

$best = [int]::MaxValue
# A stack of states to evaluate
$stack = [System.Collections.Stack]::new()

# Initial state
$stack.Push(
    [PSCustomObject]@{
        PlayerHP      = 50
        PlayerMana    = 500
        BossHP        = $bossHP
        ShieldTimer   = 0
        PoisonTimer   = 0
        RechargeTimer = 0
        ManaSpent     = 0
        PlayerTurn    = $true
    }
)

while ($stack.Count -gt 0) {
    $state = $stack.Pop()

    if ($state.ManaSpent -ge $best) { continue }

    # Hard mode: lose 1 HP at start of player turn
    if ($state.PlayerTurn) {
        $state.PlayerHP--
        if ($state.PlayerHP -le 0) { continue }
    }

    # Start of turn effects
    if ($state.PoisonTimer -gt 0) {
        $state.BossHP -= 3
        $state.PoisonTimer--
    }
    if ($state.RechargeTimer -gt 0) {
        $state.PlayerMana += 101
        $state.RechargeTimer--
    }
    if ($state.ShieldTimer -gt 0) {
        $state.ShieldTimer--
    }

    # Check boss dead
    if ($state.BossHP -le 0) {
        if ($state.ManaSpent -lt $best) {
            $best = $state.ManaSpent
        }
        continue
    }

    if ($state.PlayerTurn) {
        # Determine castable spells
        foreach ($spell in $Spells) {
            if ($spell.Cost -gt $state.PlayerMana) { continue }

            # Prevent re-casting active effect
            switch ($spell.Name) {
                'Shield' { if ($state.ShieldTimer -gt 0) { continue } }
                'Poison' { if ($state.PoisonTimer -gt 0) { continue } }
                'Recharge' { if ($state.RechargeTimer -gt 0) { continue } }
            }

            $newState = [PSCustomObject]@{
                PlayerHP      = $state.PlayerHP
                PlayerMana    = $state.PlayerMana - $spell.Cost
                BossHP        = $state.BossHP
                ShieldTimer   = $state.ShieldTimer
                PoisonTimer   = $state.PoisonTimer
                RechargeTimer = $state.RechargeTimer
                ManaSpent     = $state.ManaSpent + $spell.Cost
                PlayerTurn    = $false  # next: boss turn
            }

            if ($newState.ManaSpent -ge $best) { continue }

            if ($spell.Type -eq 'Instant') {
                $newState.BossHP -= $spell.Damage
                $newState.PlayerHP += $spell.Heal
            }
            else {
                switch ($spell.Name) {
                    'Shield' { $newState.ShieldTimer = 6 }
                    'Poison' { $newState.PoisonTimer = 6 }
                    'Recharge' { $newState.RechargeTimer = 5 }
                }
            }

            # Boss could already be dead after instant damage
            if ($newState.BossHP -le 0) {
                if ($newState.ManaSpent -lt $best) { $best = $newState.ManaSpent }
                continue
            }

            $key = "$($newState.PlayerTurn)-$($newState.PlayerHP)-$($newState.PlayerMana)-$($newState.BossHP)-$($newState.ShieldTimer)-$($newState.PoisonTimer)-$($newState.RechargeTimer)"
            if ($seen.ContainsKey($key) -and $seen[$key] -le $newState.ManaSpent) { continue }
            $seen[$key] = $newState.ManaSpent

            $stack.Push($newState)
        }
    } else {
        # Boss turn
        $armor = ($state.ShieldTimer -gt 0) ? 7 : 0
        $damage = $bossDmg - $armor
        if ($damage -lt 1) { $damage = 1 }
        $state.PlayerHP -= $damage
        if ($state.PlayerHP -le 0) { continue }

        $state.PlayerTurn = $true

        $key = "$($state.PlayerTurn)-$($state.PlayerHP)-$($state.PlayerMana)-$($state.BossHP)-$($state.ShieldTimer)-$($state.PoisonTimer)-$($state.RechargeTimer)"
        if ($seen.ContainsKey($key) -and $seen[$key] -le $state.ManaSpent) { continue }
        $seen[$key] = $state.ManaSpent

        $stack.Push($state)
    }
}

$best