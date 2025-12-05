function Merge-Ranges {
    <#
    .SYNOPSIS
        Merges overlapping or adjacent numeric ranges.
    
    .DESCRIPTION
        Takes a collection of numeric ranges and combines any that overlap or are
        adjacent to each other.
        Returns a new collection of merged ranges with no overlaps.
    
    .EXAMPLE
        Merge-Ranges -Ranges @(
            [PSCustomObject]@{
                Start=1;
                End=5
            },
            [PSCustomObject]@{
                Start=3;
                End=8
            }
        )
        Merges overlapping ranges [1,5] and [3,8] into a single range [1,8].
    
    #>
    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param(
        # Ranges of integers. Each object should have a start and end property
        [Parameter(Mandatory, Position = 0)]
        [PSCustomObject[]]
        $Ranges
    )

    # Sort by Start
    $sorted = $Ranges | Sort-Object Start, End

    if (-not $sorted) { return @() }

    $merged = [System.Collections.Generic.List[PSCustomObject]]::new()
    $current = $sorted[0]

    foreach ($next in $sorted[1..($sorted.Count - 1)]) {
        # Overlap or touch: [a,b] and [c,d] with c <= b+1
        if ($next.Start -le ($current.End + 0)) {
            # Merge
            if ($next.End -gt $current.End) {
                $current.End = $next.End
            }
        } else {
            $merged.Add($current)
            $current = $next
        }
    }
    $merged.Add($current)

    return $merged.ToArray()
}