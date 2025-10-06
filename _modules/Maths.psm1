function Get-Divisors {
    param (
        [int]
        $Number
    )

    $divisors = @()
    for ($i = 1; $i -le [math]::Sqrt($Number); $i++) {
        if ($Number % $i -eq 0) {
            $divisors += $i
            if ($i -ne $Number / $i) {
                $divisors += $Number / $i
            }
        }
    }
    return $divisors
}

function Get-DivisorSum {
    param (
        [ValidateRange(1, [int]::MaxValue)]
        [Parameter(Mandatory)]
        [int]
        $Number
    )
    $sum = 0
    $sqrtNum = [int][math]::Sqrt($Number)
    for ($i = 1; $i -le $sqrtNum; $i++) {
        if ($Number % $i -eq 0) {
            $sum += $i
            if ($i -ne $Number / $i) {
                $sum += $Number / $i
            }
        }
    }
    return $sum
}