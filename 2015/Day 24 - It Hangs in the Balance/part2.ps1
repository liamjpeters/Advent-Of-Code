<#
That's weird... the sleigh still isn't balancing.

"Ho ho ho", Santa muses to himself. "I forgot the trunk".

Balance the sleigh again, but this time, separate the packages into four groups
instead of three. The other constraints still apply.

Given the example packages above, this would be some of the new unique first
groups, their quantum entanglements, and one way to divide the remaining
packages:


11 4    (QE=44); 10 5;   9 3 2 1; 8 7
10 5    (QE=50); 11 4;   9 3 2 1; 8 7
9 5 1   (QE=45); 11 4;   10 3 2;  8 7
9 4 2   (QE=72); 11 3 1; 10 5;    8 7
9 3 2 1 (QE=54); 11 4;   10 5;    8 7
8 7     (QE=56); 11 4;   10 5;    9 3 2 1

Of these, there are three arrangements that put the minimum (two) number of
packages in the first group: 11 4, 10 5, and 8 7. Of these, 11 4 has the lowest
quantum entanglement, and so it is selected.

Now, what is the quantum entanglement of the first group of packages in the
ideal configuration?
#>

$rawInput = Get-Content "$PSScriptRoot\input.txt"

$packages = $rawInput | ForEach-Object { [int]$_ } | Sort-Object -Descending

$total = ($packages | Measure-Object -Sum | Select-Object -ExpandProperty Sum)

# Sanity check...
if ($total % 4 -ne 0) {
    throw "Can't divide packages into three groups of equal weight"
}

$target = $total / 4

function Get-CombinationsOfSizeWithSum {
    <#
      .SYNOPSIS
        Enumerate combinations of a fixed size whose elements sum to a target.
      .PARAMETER Items
        (Prefer pre-sorted descending for better pruning)
      .PARAMETER Size
        Required combination cardinality.
      .PARAMETER Sum
        Target sum.
      .OUTPUTS
        PSCustomObject with Combination (int[]) and Product (Int64)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int[]]
        $Items,
        [Parameter(Mandatory)]
        [int]
        $Size,
        [Parameter(Mandatory)]
        [int]
        $Sum
    )

    # Local recursive search with pruning
    function Recurse {
        param(
            [int]
            $Start,
            [int]
            $Count,
            [int]
            $SumSoFar,
            [long]
            $ProdSoFar,
            [System.Collections.Generic.List[int]]
            $Current
        )
        if ($SumSoFar -eq $Sum -and $Count -eq $Size) {
            [PSCustomObject]@{
                Combination = $Current.ToArray()
                Product     = $ProdSoFar
            }
            return
        }
        if ($SumSoFar -ge $Sum -or $Count -ge $Size) { return }

        for ($i = $Start; $i -lt $Items.Length; $i++) {
            $w = $Items[$i]
            if ($SumSoFar + $w -gt $Sum) { continue }
            $Current.Add($w)
            Recurse -Start ($i + 1) -Count ($Count + 1) -SumSoFar ($SumSoFar + $w) -ProdSoFar ($ProdSoFar * $w) -Current $Current
            $Current.RemoveAt($Current.Count - 1)
        }
    }

    $buffer = [System.Collections.Generic.List[int]]::new()
    Recurse -Start 0 -Count 0 -SumSoFar 0 -ProdSoFar 1 -Current $buffer
}

foreach ($size in 1..$packages.Count) {
    $combos = Get-CombinationsOfSizeWithSum -Items $packages -Size $size -Sum $target
    if ($combos.Count -gt 0) {
        $minQE = ($combos | Sort-Object -Property Product | Select-Object -First 1).Product
        "$minQE"
        break
    }
}