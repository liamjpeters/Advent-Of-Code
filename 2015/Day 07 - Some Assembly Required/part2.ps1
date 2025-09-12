<#
Now, take the signal you got on wire a, override wire b to that signal, and
reset the other wires (including wire a). What new signal is ultimately provided
to wire a?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

# Instruction types
enum InstructionType {
    ASSIGNMENT
    AND
    OR
    LSHIFT
    RSHIFT
    NOT
}

# [uint16] is 0-initialised and not nullable
# This wrapper helps us have a 'not-resolved' result
class ResolveResult {
    [bool] $isNull = $true
    [UInt16] $result = 0

    ResolveResult([bool] $isNull, [UInt16] $result) {
        $this.isNull = $isNull
        $this.result = $result
    }

}

# A class wrapper around a parsed instuction
class Instruction {
    [InstructionType] $Type
    [UInt16] $LeftParamInt
    [UInt16] $RightParamInt
    [string] $LeftParamIdentifier
    [string] $RightParamIdentifier
    [bool] $LeftLiteral = $false
    [bool] $RightLiteral = $false
    [string] $Identifier
    [UInt16] $value = 0
    [bool] $isResolved = $false

    [ResolveResult] Resolve([System.Collections.Generic.Dictionary[string, uint16]] $valStore) {
        if ($this.isResolved) {
            return $this.value
        }
        switch ($this.Type.ToString()) {
            'ASSIGNMENT' {
                # Are we assigning an int value
                if ($this.LeftLiteral) {
                    $this.value = $this.LeftParamInt
                    $this.isResolved = $true
                    return [ResolveResult]::new($false,$this.value)
                }
                # Otherwise, does the value store have a value?
                if ($valStore.ContainsKey($this.LeftParamIdentifier)) {
                    $this.value = $valStore[$this.LeftParamIdentifier]
                    $this.isResolved = $true
                    return [ResolveResult]::new($false,$this.value)
                }
                break
            }
            'NOT' {
                # Does the value store have a value?
                if ($valStore.ContainsKey($this.LeftParamIdentifier)) {
                    $this.value = $valStore[$this.LeftParamIdentifier] -bxor 65535
                    $this.isResolved = $true
                    return [ResolveResult]::new($false,$this.value)
                }
                break
            }
            'AND' {
                # Can we resolve the left parameter?
                $left = if ($this.LeftLiteral) {
                    $this.LeftParamInt
                } elseif ($valStore.ContainsKey($this.LeftParamIdentifier)) {
                    $valStore[$this.LeftParamIdentifier]
                } else {
                    return [ResolveResult]::new($true,$null)
                }
                # Can we resolve the left parameter?
                $right = if ($this.RightLiteral) {
                    $this.RightParamInt
                } elseif ($valStore.ContainsKey($this.RightParamIdentifier)) {
                    $valStore[$this.RightParamIdentifier]
                } else {
                    return [ResolveResult]::new($true,$null)
                }
                # We've resolved both values
                $this.value = $left -band $right
                $this.isResolved = $true
                return [ResolveResult]::new($false,$this.value)
            }
            'OR' {
                # Can we resolve the left parameter?
                $left = if ($this.LeftLiteral) {
                    $this.LeftParamInt
                } elseif ($valStore.ContainsKey($this.LeftParamIdentifier)) {
                    $valStore[$this.LeftParamIdentifier]
                } else {
                    return [ResolveResult]::new($true,$null)
                }
                # Can we resolve the left parameter?
                $right = if ($this.RightLiteral) {
                    $this.RightParamInt
                } elseif ($valStore.ContainsKey($this.RightParamIdentifier)) {
                    $valStore[$this.RightParamIdentifier]
                } else {
                    return [ResolveResult]::new($true,$null)
                }
                # We've resolved both values
                $this.value = $left -bor $right
                $this.isResolved = $true
                return [ResolveResult]::new($false,$this.value)
            }
            'LSHIFT' {
                # Are we assigning an int value
                if ($this.LeftLiteral) {
                    $this.value = $this.LeftParamInt -shl $this.RightParamInt
                    $this.isResolved = $true
                    return [ResolveResult]::new($false,$this.value)
                }
                # Otherwise, does the value store have a value?
                if ($valStore.ContainsKey($this.LeftParamIdentifier)) {
                    $this.value = $valStore[$this.LeftParamIdentifier] -shl $this.RightParamInt
                    $this.isResolved = $true
                    return [ResolveResult]::new($false,$this.value)
                }
                break
            }
            'RSHIFT' {
                # Are we assigning an int value
                if ($this.LeftLiteral) {
                    $this.value = $this.LeftParamInt -shr $this.RightParamInt
                    $this.isResolved = $true
                    return [ResolveResult]::new($false,$this.value)
                }
                # Otherwise, does the value store have a value?
                if ($valStore.ContainsKey($this.LeftParamIdentifier)) {
                    $this.value = $valStore[$this.LeftParamIdentifier] -shr $this.RightParamInt
                    $this.isResolved = $true
                    return [ResolveResult]::new($false,$this.value)
                }
                break
            }
            default {
                Write-Warning "Unhandled Instruction Type: '$($this.Type)'"
            }
        }
        return [ResolveResult]::new($true,$null)
    }

}

# Regex patterns to handle and parse the various instructions
$assignmentPattern = '^(\w+|\d+) -> (\w+)$'
$binaryOpPattern = '^(\w+|\d+) (AND|OR) (\w+|\d+) -> (\w+)$'
$shiftOpPattern = '^(\w+) (LSHIFT|RSHIFT) (\d+) -> (\w+)$'
$negationPattern = '^NOT (\w+) -> (\w+)$'

# A cache (array) of the parsed instructions
$instructionCache = @()

# Parse the instructions
# There are the following types of instructions:
#
# Assignment:  123 -> x
# And:         x AND y -> z
# Or:          x OR y -> z
# Left Shift:  x LSHIFT 2 -> y
# Rigth Shift: x RSHIFT 2 -> y
# Negation:    NOT y -> y
foreach ($line in $rawInput) {
    $inst = [Instruction]::new()

    # Assignment
    $match = [regex]::Match($line, $assignmentPattern)
    if ($match.Success) {
        $inst.Type = [InstructionType]::ASSIGNMENT
        $inst.Identifier = $match.Groups[2].Value
        $lParam = $match.Groups[1].Value
        if ($null -ne ($lParam -as [UInt16])) {
            $inst.LeftParamInt = $lParam -as [UInt16]
            $inst.LeftLiteral = $true
        } else {
            $inst.LeftParamIdentifier = $lParam
        }
        $instructionCache += $inst
        continue
    }

    # Binary Op
    $match = [regex]::Match($line, $binaryOpPattern)
    if ($match.Success) {
        $inst.Type = if ($match.Groups[2].Value -eq 'AND') {
            [InstructionType]::AND
        } else {
            [InstructionType]::OR
        }
        $inst.Identifier = $match.Groups[4].Value
        $lParam = $match.Groups[1].Value
        if ($null -ne ($lParam -as [UInt16])) {
            $inst.LeftParamInt = $lParam -as [UInt16]
            $inst.LeftLiteral = $true
        } else {
            $inst.LeftParamIdentifier = $lParam
        }
        $rParam = $match.Groups[3].Value
        if ($null -ne ($rParam -as [UInt16])) {
            $inst.RightParamInt = $rParam -as [UInt16]
            $inst.RightLiteral = $true
        } else {
            $inst.RightParamIdentifier = $rParam
        }
        $instructionCache += $inst
        continue
    }

    # Shift Op
    $match = [regex]::Match($line, $shiftOpPattern)
    if ($match.Success) {
        $inst.Type =  if ($match.Groups[2].Value -eq 'LSHIFT') {
            [InstructionType]::LSHIFT
        } else {
            [InstructionType]::RSHIFT
        }
        $inst.Identifier = $match.Groups[4].Value
        $lParam = $match.Groups[1].Value
        if ($null -ne ($lParam -as [UInt16])) {
            $inst.LeftParamInt = $lParam -as [UInt16]
            $inst.LeftLiteral = $true
        } else {
            $inst.LeftParamIdentifier = $lParam
        }
        $rParam = $match.Groups[3].Value
        if ($null -ne ($rParam -as [UInt16])) {
            $inst.RightParamInt = $rParam -as [UInt16]
            $inst.RightLiteral = $true
        } else {
            $inst.RightParamIdentifier = $rParam
        }
        $instructionCache += $inst
        continue
    }

    # Negation
    $match = [regex]::Match($line, $negationPattern)
    if ($match.Success) {
        $inst.Type = [InstructionType]::NOT
        $inst.Identifier = $match.Groups[2].Value
        $lParam = $match.Groups[1].Value
        if ($null -ne ($lParam -as [UInt16])) {
            $inst.LeftParamInt = $lParam -as [UInt16]
            $inst.LeftLiteral = $true
        } else {
            $inst.LeftParamIdentifier = $lParam
        }
        $instructionCache += $inst
        continue
    }

    Write-Warning "Failed to parse line '$line'"
}

# Keep a store of values
# Strongly type the keys as strings
# Strongly type the values as unsigned 16-bit integers
$valStore = [System.Collections.Generic.Dictionary[string, uint16]]::new()


# We repeatedly loop through the unresolved instructions (all are unresolved by
# default) and attempt to resolve them using the updated value store. Each newly
# resolved instruction adds information to the value store - potentially
# allowing more instructions to be resolved on the next pass.
# The resolution check, checks if we can resolve values for all operator
# arguments and if so, we can calculate it and work out the identifiers
# value. 
#
# Not the most efficient solution. Perhaps starting at the desired instruction
# and recursively resolving back to assignment statements would have been more
# efficient. This gets the job done in a reasonable amount of time though.
do{
    $numResolved = 0
    foreach ($instruction in $instructionCache) {
        if ($instruction.isResolved) {
            continue
        }
        $result = $instruction.Resolve($valStore)
        if ($result.isNull) {
            continue
        }
        $valStore.Add($instruction.Identifier,$result.result)
        $numResolved++
    }
} while ($numResolved -gt 0)

# Capture the 'a' wire value
$aVal = $valStore['a']

# Find the index of instruction with identifier 'b' in the cache
$bIndex = $instructionCache.IndexOf(($instructionCache | Where-Object {
    $_.Identifier -eq 'b'
} | Select-Object -First 1))

# Reset all instructions
foreach ($instruction in $instructionCache) {
    $instruction.value = $null
    $instruction.isResolved = $false
}

# zero out the value store
$valStore = [System.Collections.Generic.Dictionary[string, uint16]]::new()

# Set wire b to be the value we got from a
$instructionCache[$bIndex].Type = [InstructionType]::ASSIGNMENT
$instructionCache[$bIndex].LeftParamInt = $aVal
$instructionCache[$bIndex].LeftParamIdentifier = $false
$instructionCache[$bIndex].LeftLiteral = $true

# Rerun the resolution pass with the modified instruction
do{
    $numResolved = 0
    foreach ($instruction in $instructionCache) {
        if ($instruction.isResolved) {
            continue
        }
        $result = $instruction.Resolve($valStore)
        if ($result.isNull) {
            continue
        }
        $valStore.Add($instruction.Identifier,$result.result)
        $numResolved++
    }
} while ($numResolved -gt 0)

# Emit the new value for 'a'
$valStore['a']