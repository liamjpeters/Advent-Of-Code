<#
This year, Santa brought little Bobby Tables a set of wires and bitwise logic
gates! Unfortunately, little Bobby is a little under the recommended age range,
and he needs help assembling the circuit.

Each wire has an identifier (some lowercase letters) and can carry a 16-bit
signal (a number from 0 to 65535). A signal is provided to each wire by a gate,
another wire, or some specific value. Each wire can only get a signal from one
source, but can provide its signal to multiple destinations. A gate provides no
signal until all of its inputs have a signal.

The included instructions booklet describes how to connect the parts together:
x AND y -> z means to connect wires x and y to an AND gate, and then connect its
output to wire z.

For example:

- 123 -> x means that the signal 123 is provided to wire x.
- x AND y -> z means that the bitwise AND of wire x and wire y is provided to
  wire z.
- p LSHIFT 2 -> q means that the value from wire p is left-shifted by 2 and then
  provided to wire q.
- NOT e -> f means that the bitwise complement of the value from wire e is
  provided to wire f.

Other possible gates include OR (bitwise OR) and RSHIFT (right-shift). If, for
some reason, you'd like to emulate the circuit instead, almost all programming
languages (for example, C, JavaScript, or Python) provide operators for these
gates.

For example, here is a simple circuit:

123 -> x
456 -> y
x AND y -> d
x OR y -> e
x LSHIFT 2 -> f
y RSHIFT 2 -> g
NOT x -> h
NOT y -> i

After it is run, these are the signals on the wires:

d: 72
e: 507
f: 492
g: 114
h: 65412
i: 65079
x: 123
y: 456

In little Bobby's kit's instructions booklet (provided as your puzzle input),
what signal is ultimately provided to wire a?
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

# Emit the value for 'a'
$valStore['a']