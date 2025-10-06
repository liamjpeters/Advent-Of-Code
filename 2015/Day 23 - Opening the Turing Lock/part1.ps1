<#
Little Jane Marie just got her very first computer for Christmas from some
unknown benefactor. It comes with instructions and an example program, but the
computer itself seems to be malfunctioning. She's curious what the program does,
and would like you to help her run it.

The manual explains that the computer supports two registers and six
instructions (truly, it goes on to remind the reader, a state-of-the-art
technology). The registers are named a and b, can hold any non-negative integer,
and begin with a value of 0. The instructions are as follows:

- hlf r sets register r to half its current value, then continues with the
  next instruction.
- tpl r sets register r to triple its current value, then continues with the
  next instruction.
- inc r increments register r, adding 1 to it, then continues with the next
  instruction.
- jmp offset is a jump; it continues with the instruction offset away relative
  to itself.
- jie r, offset is like jmp, but only jumps if register r is even ("jump if
  even").
- jio r, offset is like jmp, but only jumps if register r is 1 ("jump if one",
  not odd).

All three jump instructions work with an offset relative to that instruction.
The offset is always written with a prefix + or - to indicate the direction of
the jump (forward or backward, respectively). For example, jmp +1 would simply
continue with the next instruction, while jmp +0 would continuously jump back to
itself forever.

The program exits when it tries to run an instruction beyond the ones defined.

For example, this program sets a to 2, because the jio instruction causes it to
skip the tpl instruction:

inc a
jio a, +2
tpl a
inc a

What is the value in register b when the program in your puzzle input is
finished executing?
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
        a = 0
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