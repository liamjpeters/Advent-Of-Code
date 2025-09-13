<#
.SYNOPSIS
    Generates all possible permutations of the input collection.

.DESCRIPTION
    The Get-Permutations function returns all unique arrangements (permutations)
    of the elements in the provided collection.
    This can be useful for combinatorial tasks, testing, or generating possible
    orderings.

.PARAMETER Collection
    The input collection (array or list) whose permutations are to be generated.

.EXAMPLE
    Get-Permutations -Collection @('A', 'B', 'C')
    Returns all possible orderings of 'A', 'B', and 'C'.

.NOTES
    The number of permutations grows factorially with the size of the input
    collection.
#>
function Get-Permutations {
    param(
        # The input collection (array or list) whose permutations are to be
        # generated.
        [Parameter(Mandatory, Position = 0)]
        [Array]
        $Items
    )

    # Check if the type already exists. If not, add it.
    if (-not ([System.Management.Automation.PSTypeName]'PermutationGenerator').Type) {
        $null = Add-Type -TypeDefinition "
            using System;
            using System.Collections.Generic;
            using System.Linq;

            public static class PermutationGenerator
            {
                public static IEnumerable<T[]> Generate<T>(T[] items)
                {
                    // Base case: If there's only one item, return it.
                    if (items.Length == 1)
                    {
                        yield return items;
                    }
                    else
                    {
                        // Recursive step
                        foreach (var item in items)
                        {
                            var remainingItems = items.Where(x => !x.Equals(item)).ToArray();
                            foreach (var subPermutation in Generate(remainingItems))
                            {
                                yield return new T[] { item }.Concat(subPermutation).ToArray();
                            }
                        }
                    }
                }
            }
        " -ReferencedAssemblies System.Linq -PassThru
    }

    # Generate the permutations and format the output
    foreach ($permutation in [PermutationGenerator]::Generate($Items)) {
        [PSCustomObject]@{ Permutation = $permutation }
    }
}

<#
.SYNOPSIS
    Generates all possible combinations of x numbers that sum up to a specified
    target value.

.DESCRIPTION
    The Get-CombinationsWithSum function generates all combinations of 
    `NumElements` elements that sum to `Sum` with a minimum value of `Min`.

.PARAMETER NumElements
    Number of elements

.PARAMETER Sum
    The target sum that each combination of numbers should add up to.

.PARAMETER Min
    The lowest value of each combination

.EXAMPLE
    PS C:\> Get-CombinationsWithSum -NumElements 2 -Sum 2 -Min 0

    Combination
    -----------
    {0, 2}
    {1, 1}
    {2, 0}

.NOTES
    Uses recursion across the number of elements
#>
function Get-CombinationsWithSum {
    param(
        # Number of elements
        [Parameter(Mandatory)]
        [int]
        $NumElements,
        # The total sum required (y)
        [Parameter(Mandatory)]
        [int]
        $Sum,
        # Minimum value for each element (z)
        [Parameter()]
        [int]
        $Min = 0
    )

    function Recurse {
        param($n, $remaining, $prefix)
        if ($n -eq 1) {
            if ($remaining -ge $Min) {
                ,(@($prefix + $remaining))
            }
        } else {
            for ($i = $Min; $i -le $remaining - $Min * ($n - 1); $i++) {
                foreach ($combo in Recurse ($n - 1) ($remaining - $i) ($prefix + $i)) {
                    ,$combo
                }
            }
        }
    }

    foreach ($combo in Recurse $NumElements $Sum @()) {
        [PSCustomObject]@{ Combination = $combo }
    }
}

<#
.SYNOPSIS
    Generates all permutations of all non-empty subsets (combinations) of the input collection.

.DESCRIPTION
    The Get-AllPermutationCombinations function returns every possible ordering (permutation)
    of every possible non-empty subset (combination) of the provided collection. This is
    equivalent to generating the power set (excluding the empty set) and then permuting each subset.
    Useful for exhaustive combinatorial analysis.

.PARAMETER Items
    The input collection (array or list) whose non-empty subsets and their permutations are to be generated.

.EXAMPLE
    Get-AllPermutationCombinations -Items @(1,2,3)
    Returns all permutations of all non-empty subsets of 1, 2, and 3.

.NOTES
    The number of results grows very rapidly with the size of the input collection:
    for n items, there are (2^n - 1) subsets, and each subset of size k has k! permutations.
#>
function Get-AllPermutationCombinations {
    param(
        # The input collection (array or list) whose non-empty subsets and their permutations are to be generated.
        [Parameter(Mandatory, Position = 0)]
        [Array]
        $Items
    )

    function Get-Subsets($arr) {
        $n = $arr.Count
        for ($i = 1; $i -lt [math]::Pow(2, $n); $i++) {
            $subset = @()
            for ($j = 0; $j -lt $n; $j++) {
                if ($i -band (1 -shl $j)) { $subset += $arr[$j] }
            }
            ,$subset
        }
    }

    foreach ($subset in Get-Subsets $Items) {
        foreach ($perm in (Get-Permutations -Items $subset)) {
            [PSCustomObject]@{ Permutation = $perm.Permutation }
        }
    }
}

<#
.SYNOPSIS
    Generates all possible non-empty combinations (subsets) of the input collection.

.DESCRIPTION
    The Get-Combinations function returns every possible non-empty subset (combination)
    of the provided collection. This is equivalent to generating the power set of the collection,
    excluding the empty set. The order of elements in each combination is preserved from the input.

.PARAMETER Items
    The input collection (array or list) whose non-empty subsets (combinations) are to be generated.

.EXAMPLE
    Get-Combinations -Items @(1,2,3)
    Returns:
    {1}
    {2}
    {3}
    {1,2}
    {1,3}
    {2,3}
    {1,2,3}

.NOTES
    For n items, there are (2^n - 1) non-empty subsets.
#>
function Get-Combinations {
    param(
        [Parameter(Mandatory, Position = 0)]
        [Array]
        $Items
    )

    $n = $Items.Count
    for ($i = 1; $i -lt [math]::Pow(2, $n); $i++) {
        $combination = @()
        for ($j = 0; $j -lt $n; $j++) {
            if ($i -band (1 -shl $j)) { $combination += $Items[$j] }
        }
        [PSCustomObject]@{ Combination = $combination }
    }
}