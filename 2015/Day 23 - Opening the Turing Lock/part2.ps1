<#
The unknown benefactor is very thankful for releasi-- er, helping little Jane
Marie with her computer. Definitely not to distract you, what is the value in
register b after the program is finished executing if register a starts as 1
instead?
#>


$rawInput = Get-Content "$PSScriptRoot\input.txt"

enum InstructionType {
    hlf # Half
    tpl # Triple
    inc # Increment
    jmp # Jump
    jie # Jump if even
    jio # Jump if one
}

class Instruction {
    [InstructionType] $Type
    [string] $Register
    [int] $Offset

    Instruction([string]$line) {
        $parts = $line -split ' '

        switch ($parts[0]) {
            'hlf' {
                $this.Type = [InstructionType]::hlf
                $this.Register = $parts[1]
                break
            }
            'tpl' {
                $this.Type = [InstructionType]::tpl
                $this.Register = $parts[1]
                break
            }
            'inc' {
                $this.Type = [InstructionType]::inc
                $this.Register = $parts[1]
                break
            }
            'jmp' {
                $this.Type = [InstructionType]::jmp
                $this.Offset = [int]$parts[1]
                break
            }
            'jie' {
                $this.Type = [InstructionType]::jie
                $this.Register = $parts[1].TrimEnd(',')
                $this.Offset = [int]$parts[2]
                break
            }
            'jio' {
                $this.Type = [InstructionType]::jio
                $this.Register = $parts[1].TrimEnd(',')
                $this.Offset = [int]$parts[2]
                break
            }
            default {
                throw "Unknown instruction type: $($parts[0])"
            }
        }
    }
}

class Cpu {
    [hashtable] $Registers = @{
        a = 1
        b = 0
    }
    [int] $ProgramCounter = 0

    Cpu() {}

    [void] Execute([Instruction[]] $program) {
        while ($this.ProgramCounter -ge 0 -and $this.ProgramCounter -lt $program.Length) {
            $instruction = $program[$this.ProgramCounter]

            switch ($instruction.Type) {
                'hlf' {
                    $this.Registers[$instruction.Register] = [math]::Floor($this.Registers[$instruction.Register] / 2)
                    $this.ProgramCounter++
                    break
                }
                'tpl' {
                    $this.Registers[$instruction.Register] *= 3
                    $this.ProgramCounter++
                    break
                }
                'inc' {
                    $this.Registers[$instruction.Register]++
                    $this.ProgramCounter++
                    break
                }
                'jmp' {
                    $this.ProgramCounter += $instruction.Offset
                    break
                }
                'jie' {
                    if ($this.Registers[$instruction.Register] % 2 -eq 0) {
                        $this.ProgramCounter += $instruction.Offset
                    } else {
                        $this.ProgramCounter++
                    }
                    break
                }
                'jio' {
                    if ($this.Registers[$instruction.Register] -eq 1) {
                        $this.ProgramCounter += $instruction.Offset
                    } else {
                        $this.ProgramCounter++
                    }
                    break
                }
            }
        }
    }

    [int] GetRegisterValue([string] $register) {
        return $this.Registers[$register]
    }

}

$program = $rawInput | ForEach-Object { [Instruction]::new($_) }

$cpu = [Cpu]::new()
$cpu.Execute($program)
$cpu.GetRegisterValue('b')